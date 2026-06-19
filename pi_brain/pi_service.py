#!/usr/bin/env python3
"""
Raspberry Pi - Complete Dual GCP Endpoint Sender
- Sends frames to YOLO VM (port 8000) for obstacle detection
- Sends frames to Gesture VM (port 8001) for hand gesture recognition
- Reads commands from Firebase for manual override
- Controls PIC via UART
"""

import serial
import threading
import time
import firebase_admin
from firebase_admin import credentials, db
import cv2
import sys
import requests
import os
import signal

# ===============================================================
# CONFIGURATION
# ===============================================================

# GCP VM Endpoints
GCP_VM_IP = "34.18.190.112"  # Your GCP VM IP

# YOLO VM (Docker container on port 8000)
YOLO_URL = f"http://{GCP_VM_IP}:8000/frame"
YOLO_API_KEY = "change-me-secret"

# Gesture VM (Python script on port 8001)
GESTURE_URL = f"http://{GCP_VM_IP}:8001/gesture"
GESTURE_API_KEY = "gesture-secret-key-123"

# Feature toggles
USE_YOLO = True
USE_GESTURE_VM = True

# ===============================================================
# FIREBASE SETUP
# ===============================================================

# Service account key path
key_path = os.path.join(os.path.dirname(__file__), "serviceAccountKey.json")

if not os.path.exists(key_path):
    print(f"❌ Firebase key not found: {key_path}")
    sys.exit(1)

cred = credentials.Certificate(key_path)
firebase_admin.initialize_app(cred, {
    "databaseURL": "https://smart-wheelchair-3f92e-default-rtdb.firebaseio.com/"
})

commands_ref = db.reference("/commands")
alerts_ref = db.reference("/alerts")
status_ref = db.reference("/status")
vitals_ref = db.reference("/vitals")

# ===============================================================
# SERIAL SETUP (PIC Communication)
# ===============================================================

try:
    ser = serial.Serial("/dev/serial0", 9600, timeout=1)
    print("✅ Serial connected to PIC")
except Exception as e:
    print(f"❌ Serial error: {e}")
    sys.exit(1)

# ===============================================================
# CONSTANTS
# ===============================================================

COMMAND_MAP = {"forward": "F", "backward": "B", "left": "L", "right": "R", "stop": "S"}
DIRECTION_MAP = {"F": "forward", "B": "backward", "L": "left", "R": "right", "S": "none"}

BPM_MIN, BPM_MAX = 50, 120
SPO2_MIN = 94

# ===============================================================
# SHARED STATE
# ===============================================================

current_command = "S"
emergency_stop = False
override_active = False
lock = threading.Lock()

frame_counter = 0
FRAME_INTERVAL = 3  # Send every 3rd frame

# ===============================================================
# SEND TO YOLO VM (Port 8000)
# ===============================================================

def send_to_yolo(frame):
    """Send frame to YOLO VM for obstacle detection"""
    if not USE_YOLO:
        return False
    
    try:
        _, jpeg = cv2.imencode(".jpg", frame, [cv2.IMWRITE_JPEG_QUALITY, 60])
        response = requests.post(
            YOLO_URL,
            data=jpeg.tobytes(),
            headers={
                "X-API-Key": YOLO_API_KEY,
                "Content-Type": "image/jpeg"
            },
            timeout=0.5
        )
        if response.status_code == 200:
            print("☁️ YOLO: OK")
            return True
        else:
            print(f"⚠️ YOLO: {response.status_code}")
            return False
    except Exception as e:
        print(f"⚠️ YOLO error: {e}")
        return False

# ===============================================================
# SEND TO GESTURE VM (Port 8001) - CORRECT FORMAT
# ===============================================================

def send_to_gesture(frame):
    """Send frame to Gesture VM for hand gesture recognition"""
    if not USE_GESTURE_VM:
        return False
    
    try:
        _, jpeg = cv2.imencode(".jpg", frame, [cv2.IMWRITE_JPEG_QUALITY, 60])
        
        # IMPORTANT: Use 'files' parameter with field name 'file'
        files = {
            'file': ('frame.jpg', jpeg.tobytes(), 'image/jpeg')
        }
        headers = {
            'X-API-Key': GESTURE_API_KEY
        }
        
        response = requests.post(
            GESTURE_URL,
            files=files,
            headers=headers,
            timeout=1.0
        )
        
        if response.status_code == 200:
            print("☁️ Gesture: OK")
            return True
        else:
            print(f"⚠️ Gesture: {response.status_code}")
            return False
    except Exception as e:
        print(f"⚠️ Gesture error: {e}")
        return False

# ===============================================================
# CAMERA FUNCTIONS
# ===============================================================

def find_working_camera():
    """Find working camera index by testing indices 0-9"""
    print("🔍 Searching for camera...")
    for i in range(10):
        try:
            cap = cv2.VideoCapture(i, cv2.CAP_V4L2)
            if cap.isOpened():
                cap.set(cv2.CAP_PROP_FRAME_WIDTH, 320)
                cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 240)
                ret, frame = cap.read()
                if ret and frame is not None:
                    print(f"✅ Camera found at index {i}")
                    cap.release()
                    return i
            cap.release()
        except Exception:
            pass
        time.sleep(0.05)
    
    print("❌ No camera found!")
    return None

# ===============================================================
# FIREBASE LISTENER (Website Commands)
# ===============================================================

def commands_listener(event):
    """Listen for commands from Firebase website dashboard"""
    global current_command, emergency_stop, override_active
    try:
        snapshot = commands_ref.get()
        if not snapshot or not isinstance(snapshot, dict):
            return

        raw_cmd = snapshot.get("command", "stop")
        e_stop = bool(snapshot.get("emergency_stop", False))
        override = bool(snapshot.get("override_active", False))
        cmd_byte = COMMAND_MAP.get(raw_cmd, "S")

        with lock:
            emergency_stop = e_stop
            override_active = override
            if override_active:
                current_command = cmd_byte

        print(f"\n[Firebase] Override: {override} | Emergency Stop: {e_stop} | Cmd: {raw_cmd}")

    except Exception as e:
        print(f"Firebase error: {e}")

# ===============================================================
# SERIAL READER (PIC Communication)
# ===============================================================

def parse_packet(line: str):
    """Parse serial data from PIC"""
    line = line.strip()
    if not line.startswith("$WC,"):
        return None
    try:
        parts = line[4:].split(",")
        if len(parts) != 10:
            return None
        return {
            "dist": int(parts[0]), "bpm": int(parts[1]), "spo2": int(parts[2]),
            "tiltX": int(parts[3]), "tiltY": int(parts[4]), "finger": int(parts[5]),
            "fall": int(parts[6]), "collision": int(parts[7]), "moving": int(parts[8])
        }
    except ValueError:
        return None

def serial_reader():
    """Read sensor data from PIC and send commands"""
    global current_command, emergency_stop, override_active
    
    while True:
        try:
            with lock:
                e_stop = emergency_stop
                cmd_byte = current_command

            # Send command to PIC
            cmd_to_send = "S" if e_stop else cmd_byte
            ser.write(cmd_to_send.encode("ascii"))

            # Read data from PIC
            raw = ser.readline().decode("ascii", errors="ignore")
            if not raw:
                continue

            data = parse_packet(raw)
            if data is None:
                if len(raw.strip()) > 0:
                    print(f"[PIC] {raw.strip()}")
                continue

            print(f"[PIC] Dist: {data['dist']}cm | Moving: {data['moving']}")

            # Update Firebase with sensor data
            finger_on = bool(data["finger"])
            vitals_abnormal = False
            if finger_on:
                vitals_abnormal = (data["bpm"] < BPM_MIN or data["bpm"] > BPM_MAX or data["spo2"] < SPO2_MIN)

            alerts_ref.update({
                "collision_warning": bool(data["collision"]),
                "fall_detected": bool(data["fall"]),
                "vitals_abnormal": vitals_abnormal,
            })

            direction = DIRECTION_MAP.get(cmd_byte, "none")
            status_ref.update({
                "is_moving": bool(data["moving"]),
                "direction": direction,
                "obstacle_distance": data["dist"],
            })

            vitals_ref.update({
                "heart_rate": data["bpm"] if finger_on else 0,
                "spo2": data["spo2"] if finger_on else 0,
                "timestamp": int(time.time()),
            })

        except Exception as e:
            time.sleep(0.1)

# ===============================================================
# MAIN FUNCTION
# ===============================================================

def main():
    print("=" * 60)
    print("🤖 RASPBERRY PI: DUAL GCP ENDPOINT SENDER")
    print("=" * 60)
    print(f"☁️ YOLO VM (port 8000): {'ON' if USE_YOLO else 'OFF'}")
    print(f"☁️ Gesture VM (port 8001): {'ON' if USE_GESTURE_VM else 'OFF'}")
    print(f"📍 GCP VM IP: {GCP_VM_IP}")
    print("=" * 60)

    # Start Firebase listener
    commands_ref.listen(commands_listener)

    # Start serial reader thread
    serial_thread = threading.Thread(target=serial_reader, daemon=True)
    serial_thread.start()

    # Find and open camera
    camera_index = find_working_camera()
    if camera_index is None:
        return

    cap = cv2.VideoCapture(camera_index, cv2.CAP_V4L2)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 320)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 240)

    if not cap.isOpened():
        print("❌ Cannot open camera")
        return

    print("✅ Camera ready")
    print("Sending frames to both VMs...\n")

    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                time.sleep(0.1)
                continue

            # Mirror frame for intuitive control
            frame = cv2.flip(frame, 1)

            global frame_counter
            frame_counter += 1

            # Send every 3rd frame
            if frame_counter % FRAME_INTERVAL == 0:
                # Send to YOLO
                if USE_YOLO:
                    send_to_yolo(frame)
                
                # Send to Gesture VM
                if USE_GESTURE_VM:
                    send_to_gesture(frame)

            # Small delay to control CPU usage
            time.sleep(0.1)

    except KeyboardInterrupt:
        print("\n🛑 Stopping by user...")
    finally:
        with lock:
            current_command = 'S'
        cap.release()
        if ser and ser.is_open:
            ser.close()
        print("✅ Done!")

if __name__ == "__main__":
    main()