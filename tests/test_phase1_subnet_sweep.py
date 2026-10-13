#!/usr/bin/env python3
"""
Automated Conformance Test Suite for DotLan Phase 1: Subnet Sweep & CIDR Slicing.

Validates:
- CIDR netmask parsing and IP conversions.
- IPv4 network, broadcast, and host range calculations.
- Enterprise /16 and /8 bounded slicing to prevent file descriptor starvation.
- RFC 1918 Private and RFC 6598 CGNAT space identification.
- TCP RST affirmative host alive logic.
"""

import unittest

def ip_to_int(ip: str) -> int:
    parts = [int(p) for p in ip.split('.')]
    return (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3]

def int_to_ip(val: int) -> str:
    return f"{(val >> 24) & 0xFF}.{(val >> 16) & 0xFF}.{(val >> 8) & 0xFF}.{val & 0xFF}"

def netmask_to_prefix(netmask: str) -> int:
    mask_int = ip_to_int(netmask)
    count = 0
    for i in range(31, -1, -1):
        if (mask_int & (1 << i)) != 0:
            count += 1
        else:
            break
    return count if count > 0 else 24

def calculate_subnet(local_ip: str, netmask: str = "255.255.255.0", override_prefix: int = None):
    prefix = override_prefix if override_prefix is not None else netmask_to_prefix(netmask)
    ip_int = ip_to_int(local_ip)
    mask_int = (~0 << (32 - prefix)) & 0xFFFFFFFF if prefix > 0 else 0

    network_int = ip_int & mask_int
    broadcast_int = network_int | (~mask_int & 0xFFFFFFFF)

    first_host = network_int + 1
    last_host = broadcast_int - 1
    total = (last_host - first_host + 1) if last_host >= first_host else 0

    is_enterprise = prefix < 23
    targets = []

    if not is_enterprise and total <= 512:
        for i in range(first_host, last_host + 1):
            targets.append(int_to_ip(i))
    else:
        # Bounded slice of immediate /24 neighborhood
        octets = local_ip.split('.')
        base = f"{octets[0]}.{octets[1]}.{octets[2]}"
        for i in range(1, 255):
            targets.append(f"{base}.{i}")

    return {
        "network": int_to_ip(network_int),
        "broadcast": int_to_ip(broadcast_int),
        "first_host": int_to_ip(first_host),
        "last_host": int_to_ip(last_host),
        "total_hosts": total,
        "prefix": prefix,
        "is_enterprise": is_enterprise,
        "target_count": len(targets),
        "targets": targets
    }

def is_private_ip(ip: str) -> bool:
    p = [int(x) for x in ip.split('.')]
    if p[0] == 10:
        return True
    if p[0] == 172 and (16 <= p[1] <= 31):
        return True
    if p[0] == 192 and p[1] == 168:
        return True
    return False

def is_cgnat_ip(ip: str) -> bool:
    p = [int(x) for x in ip.split('.')]
    return p[0] == 100 and (64 <= p[1] <= 127)

def evaluate_socket_result(connect_error_msg: str) -> bool:
    """Evaluates if a TCP connect error represents an affirmative alive host (TCP RST)"""
    err = connect_error_msg.lower()
    if "connection refused" in err or "econnrefused" in err:
        return True # Host is ALIVE (sent TCP RST)
    return False # Timeout, unreachable, or firewall drop

class TestPhase1SubnetSweep(unittest.TestCase):

    def test_standard_slash_24_calculation(self):
        sub = calculate_subnet("192.168.1.45", "255.255.255.0")
        self.assertEqual(sub["network"], "192.168.1.0")
        self.assertEqual(sub["broadcast"], "192.168.1.255")
        self.assertEqual(sub["first_host"], "192.168.1.1")
        self.assertEqual(sub["last_host"], "192.168.1.254")
        self.assertEqual(sub["total_hosts"], 254)
        self.assertEqual(sub["prefix"], 24)
        self.assertFalse(sub["is_enterprise"])
        self.assertEqual(sub["target_count"], 254)
        self.assertEqual(sub["targets"][0], "192.168.1.1")
        self.assertEqual(sub["targets"][-1], "192.168.1.254")

    def test_enterprise_slash_16_bounded_slicing(self):
        # Campus / Hotel network: 10.14.3.45 / 255.255.0.0 (/16)
        sub = calculate_subnet("10.14.3.45", "255.255.0.0")
        self.assertEqual(sub["prefix"], 16)
        self.assertEqual(sub["total_hosts"], 65534)
        self.assertTrue(sub["is_enterprise"])
        # Must be bounded to exactly 254 neighborhood hosts to protect socket limits!
        self.assertEqual(sub["target_count"], 254)
        self.assertEqual(sub["targets"][0], "10.14.3.1")
        self.assertEqual(sub["targets"][-1], "10.14.3.254")

    def test_tcp_rst_affirmative_detection(self):
        # Connection refused means host sent TCP RST -> Confirmed host alive!
        self.assertTrue(evaluate_socket_result("java.net.ConnectException: Connection refused"))
        self.assertTrue(evaluate_socket_result("ECONNREFUSED: Connection refused by peer"))
        # Timeout or host unreachable means host dead or firewall dropped
        self.assertFalse(evaluate_socket_result("java.net.SocketTimeoutException: Connect timed out"))
        self.assertFalse(evaluate_socket_result("EHOSTUNREACH: No route to host"))

    def test_private_and_cgnat_ranges(self):
        self.assertTrue(is_private_ip("192.168.1.1"))
        self.assertTrue(is_private_ip("10.0.0.1"))
        self.assertTrue(is_private_ip("172.20.14.5"))
        self.assertFalse(is_private_ip("8.8.8.8"))
        self.assertFalse(is_private_ip("100.64.0.1"))

        # RFC 6598 Carrier-Grade NAT (100.64.0.0/10)
        self.assertTrue(is_cgnat_ip("100.64.1.1"))
        self.assertTrue(is_cgnat_ip("100.127.255.254"))
        self.assertFalse(is_cgnat_ip("100.63.255.255"))
        self.assertFalse(is_cgnat_ip("100.128.0.1"))

if __name__ == "__main__":
    unittest.main()
