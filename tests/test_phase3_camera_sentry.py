#!/usr/bin/env python3
"""
Automated Conformance Test Suite for DotLan Phase 3: Camera Sentry & Protocol Verification.

Validates:
- RTSP RFC 2326 OPTIONS handshake banner parsing.
- ONVIF camera HTTP banner detection.
- False positive clearing on standard web servers.
- Traveler Room Safety Score formula.
"""

import unittest

def parse_rtsp_options_response(raw_resp: str) -> dict:
    if "RTSP/1.0 200 OK" in raw_resp or "RTSP/2.0 200 OK" in raw_resp or ("RTSP/" in raw_resp and "Public:" in raw_resp):
        banner = "Generic RTSP Server"
        for line in raw_resp.split("\r\n"):
            if line.lower().startswith("server:"):
                banner = line[7:].strip()
                break
        return {
            "is_confirmed": True,
            "banner": banner,
            "confidence": 0.98
        }
    return {
        "is_confirmed": False,
        "banner": "None",
        "confidence": 0.0
    }

def evaluate_http_camera_banner(raw_resp: str) -> dict:
    lower = raw_resp.lower()
    camera_signatures = ['boa', 'goahead', 'hikvision', 'dahua', 'ipcamera', 'onvif', 'realm="ip camera"']
    if any(sig in lower for sig in camera_signatures):
        return {
            "is_camera": True,
            "details": "Verified Camera Firmware",
            "confidence": 0.95
        }
    # Standard web servers (Python, Apache, Nginx) are explicitly cleared!
    return {
        "is_camera": False,
        "details": "Generic Web Server (Cleared)",
        "confidence": 0.0
    }

def compute_room_safety_score(total_devices: int, confirmed_cameras: int, suspected_cameras: int) -> int:
    if confirmed_cameras > 0:
        val = 30 - (confirmed_cameras * 10)
        return max(0, min(val, 40))
    if suspected_cameras > 0:
        return 65
    return 100

class TestPhase3CameraSentry(unittest.TestCase):

    def test_rtsp_options_parsing(self):
        sample_rtsp_200 = (
            "RTSP/1.0 200 OK\r\n"
            "CSeq: 1\r\n"
            "Public: OPTIONS, DESCRIBE, SETUP, TEARDOWN, PLAY, PAUSE\r\n"
            "Server: Hikvision-RTSP/2.0\r\n\r\n"
        )
        res = parse_rtsp_options_response(sample_rtsp_200)
        self.assertTrue(res["is_confirmed"])
        self.assertEqual(res["banner"], "Hikvision-RTSP/2.0")
        self.assertGreaterEqual(res["confidence"], 0.95)

    def test_false_positive_elimination(self):
        # Python dev server running on port 8000
        python_http = (
            "HTTP/1.0 200 OK\r\n"
            "Server: SimpleHTTP/0.6 Python/3.12.0\r\n"
            "Content-Type: text/html\r\n\r\n"
        )
        res = evaluate_http_camera_banner(python_http)
        self.assertFalse(res["is_camera"]) # Must NOT alert as a camera!

        # Genuine Boa IP camera on port 8000
        boa_cam = (
            "HTTP/1.0 401 Unauthorized\r\n"
            "Server: Boa/0.94.14rc21\r\n"
            "WWW-Authenticate: Basic realm=\"IP Camera Login\"\r\n\r\n"
        )
        cam_res = evaluate_http_camera_banner(boa_cam)
        self.assertTrue(cam_res["is_camera"]) # Must confirm camera!

    def test_safety_clearance_score(self):
        # 100% when no cameras detected
        self.assertEqual(compute_room_safety_score(15, 0, 0), 100)

        # Penalized when suspected stream exists
        self.assertEqual(compute_room_safety_score(15, 0, 1), 65)

        # Critical penalty when confirmed camera exists
        self.assertEqual(compute_room_safety_score(15, 1, 0), 20)
        self.assertEqual(compute_room_safety_score(15, 3, 0), 0)

if __name__ == "__main__":
    unittest.main()
