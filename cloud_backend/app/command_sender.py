import json
import time
from fastapi import WebSocket
from app.state import Command

class CommandHub:
    def __init__(self):
        self.ws_clients: set[WebSocket] = set()
        self._latest: Command = Command()
    
    async def register(self, ws): self.ws_clients.add(ws)
    async def unregister(self, ws): self.ws_clients.discard(ws)
    
    async def broadcast(self, cmd: Command):
        self._latest = cmd
        if not self.ws_clients: return
        payload = json.dumps({
            "action": cmd.action, "speed": cmd.speed,
            "reason": cmd.reason, "ts": cmd.timestamp,
        })
        for ws in list(self.ws_clients):
            try: await ws.send_text(payload)
            except: self.ws_clients.discard(ws)
    
    def get_latest(self) -> dict:
        return {
            "action": self._latest.action,
            "speed": self._latest.speed,
            "reason": self._latest.reason,
            "ts": self._latest.timestamp,
            "age_ms": (time.time() - self._latest.timestamp) * 1000 if self._latest.timestamp else None,
        }

command_hub = CommandHub()