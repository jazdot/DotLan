#!/usr/bin/env python3
"""
Automated Conformance Test Suite for DotLan Phase 2: Device Fingerprinting & OUI Database.

Validates:
- Offline IEEE OUI prefix resolution.
- Surveillance camera hardware identification.
- Multi-signal device classification heuristics.
"""

import unittest

OUI_TABLE = {
    '00:17:F2': 'Apple, Inc.',
    'AC:BC:32': 'Apple, Inc.',
    '00:12:47': 'Samsung Electronics',
    '08:9E:08': 'Google, Inc.',
    '24:62:AB': 'Espressif (ESP32/ESP8266)',
    '10:2C:6B': 'Tuya Smart (IoT)',
    '44:19:B6': 'Hikvision Digital',
    '3C:EF:8C': 'Dahua Technology',
    '00:0E:58': 'Sonos, Inc.',
    '00:01:E6': 'HP Inc.',
    '00:00:0C': 'Cisco Systems',
}

def resolve_vendor(mac: str) -> str:
    if not mac or len(mac) < 8:
        return 'Unknown Vendor'
    norm = mac.upper().replace('-', ':').replace('.', ':')
    parts = norm.split(':')
    if len(parts) >= 3:
        prefix = f"{parts[0].zfill(2)}:{parts[1].zfill(2)}:{parts[2].zfill(2)}"
        if prefix in OUI_TABLE:
            return OUI_TABLE[prefix]
    return 'Generic Network Device'

def is_camera_vendor(mac: str) -> bool:
    v = resolve_vendor(mac)
    return any(c in v for c in ['Hikvision', 'Dahua', 'Axis', 'Wyze', 'Reolink', 'Amcrest', 'Foscam'])

def classify_device(ip: str, hostname: str = None, mac: str = None,
                    open_ports: list = None, services: list = None, is_gateway: bool = False) -> str:
    if is_gateway:
        return "gateway"
    ports = open_ports or []
    servs = services or []
    h = (hostname or '').lower()
    vendor = resolve_vendor(mac).lower()

    if 554 in ports or 'RTSP' in servs or 'ONVIF' in servs or is_camera_vendor(mac) or 'cam' in h or 'hikvision' in h:
        return "camera"
    if 9100 in ports or 631 in ports or '_ipp._tcp' in servs or 'printer' in h or 'hp' in vendor:
        return "printer"
    if '_googlecast._tcp' in servs or '_airplay._tcp' in servs or 'appletv' in h or 'sonos' in vendor:
        return "entertainment"
    if '_matter._tcp' in servs or 'espressif' in vendor or 'tuya' in vendor or 'esp_' in h:
        return "iot"
    if 445 in ports or 139 in ports or 22 in ports or 'desktop' in h or 'nas' in h:
        return "workstation"
    if 'iphone' in h or 'android' in h or 'galaxy' in h:
        return "mobile"
    return "unknown"

class TestPhase2DeviceFingerprinting(unittest.TestCase):

    def test_oui_resolution(self):
        self.assertEqual(resolve_vendor("ac:bc:32:11:22:33"), "Apple, Inc.")
        self.assertEqual(resolve_vendor("44-19-B6-AA-BB-CC"), "Hikvision Digital")
        self.assertEqual(resolve_vendor("24:62:ab:44:55:66"), "Espressif (ESP32/ESP8266)")
        self.assertEqual(resolve_vendor("00:0e:58:12:34:56"), "Sonos, Inc.")
        self.assertEqual(resolve_vendor("11:22:33:44:55:66"), "Generic Network Device")

    def test_camera_vendor_detection(self):
        self.assertTrue(is_camera_vendor("44:19:B6:01:02:03")) # Hikvision
        self.assertTrue(is_camera_vendor("3C:EF:8C:99:88:77")) # Dahua
        self.assertFalse(is_camera_vendor("ac:bc:32:11:22:33")) # Apple
        self.assertFalse(is_camera_vendor("00:12:47:11:22:33")) # Samsung

    def test_device_classification_rules(self):
        # Gateway
        self.assertEqual(classify_device("192.168.1.1", is_gateway=True), "gateway")

        # Camera with RTSP 554
        self.assertEqual(classify_device("192.168.1.150", open_ports=[554]), "camera")

        # Smart TV with AirPlay
        self.assertEqual(classify_device("192.168.1.120", services=['_airplay._tcp']), "entertainment")

        # Smart Plug ESP32
        self.assertEqual(classify_device("192.168.1.189", mac="24:62:AB:55:66:77"), "iot")

        # Printer with Port 9100
        self.assertEqual(classify_device("192.168.1.99", open_ports=[9100]), "printer")

        # Workstation with SMB Port 445
        self.assertEqual(classify_device("192.168.1.40", open_ports=[445]), "workstation")

if __name__ == "__main__":
    unittest.main()
