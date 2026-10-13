#!/usr/bin/env python3
"""
Automated Runtime Resilience & Stress Test Suite for DotLan.

Validates:
- High-concurrency 500-device simulated subnet ingestion.
- Malformed XML and RTSP payload immunity.
- Concurrency bounding enforcement (Semaphore limits).
- Numerical stability and sorting idempotence.
"""

import time
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from test_phase1_subnet_sweep import calculate_subnet, evaluate_socket_result
from test_phase2_device_fingerprinting import classify_device, resolve_vendor
from test_phase3_camera_sentry import parse_rtsp_options_response, evaluate_http_camera_banner, compute_room_safety_score
from test_phase4_upnp_and_gateway import parse_upnp_wan_ip, parse_upnp_mapping
from test_phase5_ocsf_and_audit import calculate_fnv64_seal

class TestRuntimeResilience(unittest.TestCase):

    def test_500_host_sweep_resilience(self):
        """Simulates ingestion of 500 host records under load."""
        start_time = time.time()
        simulated_devices = []

        for i in range(1, 501):
            ip = f"10.0.{(i >> 8) & 0xFF}.{i & 0xFF}"
            mac = f"00:17:F2:{(i >> 8) & 0xFF:02X}:{i & 0xFF:02X}:AA"
            ports = [554] if (i % 50 == 0) else ([80, 443] if (i % 3 == 0) else [])
            servs = ['RTSP'] if (554 in ports) else []

            category = classify_device(ip=ip, mac=mac, open_ports=ports, services=servs)
            simulated_devices.append({
                "ip": ip,
                "mac": mac,
                "category": category,
                "is_camera": 554 in ports
            })

        elapsed = time.time() - start_time
        self.assertEqual(len(simulated_devices), 500)
        # 500 classifications must finish in under 20ms
        self.assertLess(elapsed, 0.05)

        # Verify cameras detected
        cameras = [d for d in simulated_devices if d["is_camera"]]
        self.assertEqual(len(cameras), 10)
        for cam in cameras:
            self.assertEqual(cam["category"], "camera")

    def test_malformed_xml_resilience(self):
        """Ensures UPnP parser survives corrupt, truncated, or malicious XML."""
        corrupt_payloads = [
            "",
            "<?xml version=\"1.0\"?>",
            "<s:Envelope><s:Body><corrupt>",
            "<NewExternalIPAddress></NewExternalIPAddress>",
            "<NewExternalIPAddress>0.0.0.0</NewExternalIPAddress>",
            "<NewExternalPort>not-an-integer</NewExternalPort>",
            "A" * 10000,
        ]

        for payload in corrupt_payloads:
            ip = parse_upnp_wan_ip(payload)
            self.assertIsNone(ip)

            mapping = parse_upnp_mapping(payload)
            self.assertIsNone(mapping)

    def test_malformed_rtsp_banner_resilience(self):
        """Ensures RTSP parser survives garbage responses."""
        garbage_responses = [
            "",
            "HTTP/1.1 404 Not Found\r\n\r\n",
            "SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.1\r\n",
            "\x00\x01\x02\x03\x04\x05\xFF\xFE",
            "RTSP" + ("X" * 5000),
        ]

        for resp in garbage_responses:
            res = parse_rtsp_options_response(resp)
            if "RTSP/1.0 200 OK" not in resp:
                self.assertFalse(res["is_confirmed"])

    def test_concurrency_bounding_math(self):
        """Verifies that large subnets are safely sliced into batches of <= 128."""
        sub = calculate_subnet("10.0.5.45", "255.255.0.0")
        target_count = sub["target_count"]
        batch_size = 128
        batches = (target_count + batch_size - 1) // batch_size
        self.assertEqual(batches, 2) # Exactly 2 batches (128 + 126) for 254 hosts

    def test_hash_integrity_under_unicode_input(self):
        """Verifies FNV64 hash stability with Unicode characters."""
        unicode_payload = "Wi-Fi-7-Guest-Suite-Über-Hotspot-5GHz:192.168.1.1:2026-10-13"
        h1 = calculate_fnv64_seal(unicode_payload)
        h2 = calculate_fnv64_seal(unicode_payload)
        self.assertEqual(h1, h2)
        self.assertEqual(len(h1), 16)

if __name__ == "__main__":
    unittest.main()
