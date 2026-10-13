#!/usr/bin/env python3
"""
Automated Conformance Test Suite for DotLan Phase 4: UPnP Gateway & Port Forward Audit.

Validates:
- UPnP IGD XML SOAP extraction for WAN IP.
- UPnP port forward mapping parser.
- High-risk external WAN exposure classification.
"""

import re
import unittest

def parse_upnp_wan_ip(soap_xml: str) -> str:
    match = re.search(r'<NewExternalIPAddress>(.*?)</NewExternalIPAddress>', soap_xml)
    if match and match.group(1):
        ip = match.group(1).strip()
        if ip and ip != "0.0.0.0":
            return ip
    return None

def parse_upnp_mapping(soap_xml: str) -> dict:
    ext_match = re.search(r'<NewExternalPort>(.*?)</NewExternalPort>', soap_xml)
    int_match = re.search(r'<NewInternalPort>(.*?)</NewInternalPort>', soap_xml)
    client_match = re.search(r'<NewInternalClient>(.*?)</NewInternalClient>', soap_xml)
    proto_match = re.search(r'<NewProtocol>(.*?)</NewProtocol>', soap_xml)
    desc_match = re.search(r'<NewPortMappingDescription>(.*?)</NewPortMappingDescription>', soap_xml)

    if ext_match and int_match and client_match:
        ext_port = int(ext_match.group(1))
        return {
            "external_port": ext_port,
            "internal_port": int(int_match.group(1)),
            "internal_client": client_match.group(1),
            "protocol": proto_match.group(1) if proto_match else "TCP",
            "description": desc_match.group(1) if desc_match else "Mapping",
            "is_high_risk": ext_port in [3389, 22, 23, 445, 554, 8000, 80, 443]
        }
    return None

class TestPhase4UpnpAndGateway(unittest.TestCase):

    def test_upnp_wan_ip_extraction(self):
        sample_soap = """<?xml version="1.0"?>
        <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
          <s:Body>
            <u:GetExternalIPAddressResponse xmlns:u="urn:schemas-upnp-org:service:WANIPConnection:1">
              <NewExternalIPAddress>198.51.100.42</NewExternalIPAddress>
            </u:GetExternalIPAddressResponse>
          </s:Body>
        </s:Envelope>"""

        wan = parse_upnp_wan_ip(sample_soap)
        self.assertEqual(wan, "198.51.100.42")

    def test_upnp_port_mapping_parsing(self):
        # High-risk exposed RDP port 3389
        rdp_soap = """<?xml version="1.0"?>
        <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
          <s:Body>
            <u:GetGenericPortMappingEntryResponse xmlns:u="urn:schemas-upnp-org:service:WANIPConnection:1">
              <NewExternalPort>3389</NewExternalPort>
              <NewInternalPort>3389</NewInternalPort>
              <NewInternalClient>192.168.1.105</NewInternalClient>
              <NewProtocol>TCP</NewProtocol>
              <NewPortMappingDescription>Remote Desktop Service</NewPortMappingDescription>
            </u:GetGenericPortMappingEntryResponse>
          </s:Body>
        </s:Envelope>"""

        mapping = parse_upnp_mapping(rdp_soap)
        self.assertIsNotNone(mapping)
        self.assertEqual(mapping["external_port"], 3389)
        self.assertEqual(mapping["internal_client"], "192.168.1.105")
        self.assertTrue(mapping["is_high_risk"])

        # Low-risk custom gaming port
        game_soap = """<?xml version="1.0"?>
        <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
          <s:Body>
            <u:GetGenericPortMappingEntryResponse xmlns:u="urn:schemas-upnp-org:service:WANIPConnection:1">
              <NewExternalPort>27015</NewExternalPort>
              <NewInternalPort>27015</NewInternalPort>
              <NewInternalClient>192.168.1.112</NewInternalClient>
              <NewProtocol>UDP</NewProtocol>
              <NewPortMappingDescription>Steam Peer Server</NewPortMappingDescription>
            </u:GetGenericPortMappingEntryResponse>
          </s:Body>
        </s:Envelope>"""

        game_mapping = parse_upnp_mapping(game_soap)
        self.assertIsNotNone(game_mapping)
        self.assertFalse(game_mapping["is_high_risk"])

if __name__ == "__main__":
    unittest.main()
