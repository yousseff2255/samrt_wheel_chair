# telemetry.py
import json
from fastapi import WebSocket

class TelemetryHub:
    def __init__(self):
        self.clients: set[WebSocket] = set()
    async def register(self, ws): self.clients.add(ws)
    async def unregister(self, ws): self.clients.discard(ws)
    async def broadcast(self, payload: dict):
        if not self.clients: return
        msg = json.dumps(payload)
        for ws in list(self.clients):
            try: await ws.send_text(msg)
            except: self.clients.discard(ws)

telemetry_hub = TelemetryHub()