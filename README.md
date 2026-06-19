---
# ♿ Smart Wheelchair Ecosystem

Welcome to the complete repository for the **Smart Wheelchair** project! This ecosystem combines low-level hardware safety, high-performance cloud computer vision, multimodal mobile app control, and real-time remote telemetry into a unified assist-tech platform.
---

## 🏗️ System Architecture

The project is split into four distinct layers that communicate seamlessly with each other:

```text
                                  ┌───────────────────────┐
                                  │      GCP Cloud        │
                                  │  (Advanced AI Models) │
                                  └──────────▲────────────┘
                                             │ HTTPS
                                             ▼ (Inference)
┌────────────────┐      UART      ┌───────────────────────┐
│  PIC16F877A    │ ◄────────────► │     Raspberry Pi      │
│ (Safety & Hub) │    (9600)      │  (Gateway & Camera)   │
└───────┬────────┘                └───────────────────────┘
        │
   (I2C/Sensors)
        ▼                                    ▲ Firebase
   Motors & Alarms                           │ (Sync)
                                             ▼
                                  ┌───────────────────────┐
                                  │   Mobile App (User)   │
                                  │ ── ── ── ── ── ── ──  │
                                  │  • Arrows • Gestures  │
                                  │  • Voice Control      │
                                  └───────────────────────┘

```

---

## 📁 Repository & Modules Layout

```text
smart_wheel_chair/
├── pic_firmware/         # Low-level safety state machine, sensor driver hub, motor controls
├── pi_brain/           # Camera streaming, GCP API bridge, UART parser, Firebase client
├── mobile_app/           # User app featuring touchscreen UI, voice processing, and gesture control
└── cloud_backend/        # GCP Vision/ML endpoints, Firebase Realtime Database, and telehealth logs

```

---

## 💻 Module Breakdowns

### 1. Low-Level Control Layer (PIC16F877A)

- **Role:** Acts as the dedicated safety officer and physical sensor aggregator. It talks directly to the hardware and handles critical events instantly.
- **Safety Rules:** If a fall is detected, it overrides all inputs and freezes the wheels instantly.
- If an obstacle gets too close, it locks forward movement but allows escape steering.

- **Peripherals:** MPU6050 (Tilt), MAX30102 (Heart Rate/SpO2), Ultrasonic, 16x2 LCD, and DC Motors.

### 2. High-Level Compute & Gateway (Raspberry Pi)

- **Role:** Acts as the communication bridge, video capture node, and local edge coordinator.
- **Core Logic:**
- Constantly captures frames from the onboard camera module.
- Streams these images securely to hosted Machine Learning models running on **Google Cloud Platform (GCP)** for real-time visual assessment and command inference.
- Receives processing results back from GCP and immediately translates them into low-level directional steering commands (`'F'`, `'B'`, `'L'`, `'R'`, `'S'`).
- Passes those tokens down to the PIC over a stable **9600 Baud UART** link.

### 3. Cloud Infrastructure (GCP & Firebase)

- **Role:** Houses the system's intelligence and handles global synchronization.
- **Google Cloud Platform (GCP):** Hosts heavy-duty computer vision and deep learning models to process the environment or complex user inputs without slowing down edge hardware.
- **Firebase Realtime Database:** \* Syncs active telemetry (speed, tilt coordinates, active alerts, user heart rate, and SpO2 levels).
- Pipelines directional driving overrides sent over the network directly to the wheelchair.

### 4. Companion Multimodal Mobile Application

- **Role:** Offers total flexibility for the operator or caregiver to command the chair using three distinct input methods:
- **On-Screen Directional Arrows:** Classic touch layout for straightforward manual joystick maneuvering.
- **Audio/Voice Instructions:** Integrated speech-to-text processing allowing users to navigate via vocalized commands (e.g., "Move Forward", "Stop").
- **Specific Device Gestures:** Utilizes the smartphone's built-in accelerometer/gyroscope or camera to map custom hand/phone movements directly to physical wheelchair steering.
- **Health Dashboard:** Continuously pulls medical and positional alerts from Firebase for live feedback.

---

## 📡 End-to-End Control Pipeline

1. **Input:** The chair captures external commands either visually (Pi Camera streaming frames to **GCP**) or manually (Mobile App via **Voice, Gestures, or UI Arrows** pushing states to **Firebase**).
2. **Arbitrate:** The Raspberry Pi collects the winning command state and forwards it down to the PIC16F877A.
3. **Execute:** The PIC confirms the path is safe via ultrasonic and IMU metrics. If clear, it fires the motor drivers; if a hazard is present, it triggers the buzzer and forces a safe stop.
