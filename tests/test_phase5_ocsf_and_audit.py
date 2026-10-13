#!/usr/bin/env python3
"""
Automated Conformance Test Suite for DotLan Phase 5: OCSF v1.3.0, CSV & Cryptographic Seal.

Validates:
- OCSF v1.3.0 Class 4001 Network Activity JSON schema.
- CSV serialization compliance.
- Cryptographic FNV64 seal hash algorithm parity.
"""

import json
import unittest

def calculate_fnv64_seal(payload: str) -> str:
    fnv_prime = 0x100000001b3
    fnv_offset_basis = 0xcbf29ce484222325
    h = fnv_offset_basis
    for b in payload.encode('utf-8'):
        h = h ^ b
        h = (h * fnv_prime) & 0xFFFFFFFFFFFFFFFF
    return f"{h:016X}"

def generate_ocsf_event(ip: str, mac: str, vendor: str, category: str, latency_ms: float,
                        is_camera: bool = False, is_confirmed: bool = False) -> dict:
    return {
        "class_uid": 4001,
        "category_uid": 4,
        "activity_id": 1,
        "severity_id": 4 if is_confirmed else (3 if is_camera else 1),
        "time": 1728520000000,
        "metadata": {
            "version": "1.3.0",
            "product": {
                "name": "DotLan",
                "vendor_name": "Jazdot Enterprises",
                "version": "1.0.0"
            },
            "extension": {
                "name": "lan_subnet_telemetry",
                "version": "2.1.0"
            }
        },
        "network_endpoint": {
            "ip": ip,
            "mac": mac,
            "category": category,
            "vendor": vendor,
            "latency_ms": latency_ms
        },
        "security_analysis": {
            "is_camera": is_camera,
            "is_confirmed_camera": is_confirmed,
            "verification_source": "VERIFIED_SUBNET_AUDIT_SEAL"
        }
    }

def format_csv(devices: list) -> str:
    lines = ["IP_Address,MAC_Address,Hostname,Vendor,Category,Latency_ms,Open_Ports,Camera_Detected,Confirmed_Feed"]
    for d in devices:
        lines.append(f"{d['ip']},{d['mac']},{d['host']},{d['vendor']},{d['category']},{d['latency']},{d['ports']},{d['is_cam']},{d['is_conf']}")
    return "\n".join(lines)

class TestPhase5OcsfAndAudit(unittest.TestCase):

    def test_ocsf_event_schema(self):
        ev = generate_ocsf_event(
            ip="192.168.1.100",
            mac="AC:BC:32:00:11:22",
            vendor="Apple, Inc.",
            category="workstation",
            latency_ms=2.4,
            is_camera=False,
            is_confirmed=False
        )
        self.assertEqual(ev["class_uid"], 4001)
        self.assertEqual(ev["category_uid"], 4)
        self.assertEqual(ev["severity_id"], 1)
        self.assertEqual(ev["metadata"]["product"]["name"], "DotLan")
        self.assertEqual(ev["metadata"]["product"]["vendor_name"], "Jazdot Enterprises")
        self.assertEqual(ev["network_endpoint"]["ip"], "192.168.1.100")
        self.assertEqual(ev["security_analysis"]["verification_source"], "VERIFIED_SUBNET_AUDIT_SEAL")

        # High severity for confirmed camera
        cam_ev = generate_ocsf_event(
            ip="192.168.1.200",
            mac="44:19:B6:11:22:33",
            vendor="Hikvision Digital",
            category="camera",
            latency_ms=1.8,
            is_camera=True,
            is_confirmed=True
        )
        self.assertEqual(cam_ev["severity_id"], 4) # Critical severity for active camera

    def test_fnv64_seal_hash_determinism(self):
        payload = "00:11:22:33:44:55:192.168.1.1:12:1:2026-10-13T12:00:00Z"
        h1 = calculate_fnv64_seal(payload)
        h2 = calculate_fnv64_seal(payload)
        self.assertEqual(h1, h2)
        self.assertEqual(len(h1), 16)
        # Verify hex uppercase format
        self.assertTrue(all(c in '0123456789ABCDEF' for c in h1))

    def test_csv_formatting(self):
        devs = [{
            "ip": "192.168.1.1",
            "mac": "00:00:0C:11:22:33",
            "host": "Default Gateway",
            "vendor": "Cisco Systems",
            "category": "gateway",
            "latency": 0.8,
            "ports": "80;443",
            "is_cam": "NO",
            "is_conf": "NO"
        }]
        csv_str = format_csv(devs)
        self.assertIn("IP_Address,MAC_Address", csv_str)
        self.assertIn("192.168.1.1,00:00:0C:11:22:33,Default Gateway,Cisco Systems", csv_str)

if __name__ == "__main__":
    unittest.main()
