# DotLan — Ad-Free Local Subnet Discovery, Smart IoT & Camera Radar

[![Jazdot Enterprises](https://img.shields.io/badge/JAZDOT-ENTERPRISES-D97706?style=flat-square)](https://jazdot.com)
[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-blue?style=flat-square)](#)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.10+-02569B?style=flat-square&logo=flutter)](#)
[![Android API](https://img.shields.io/badge/Android-API%2033--36-3DDC84?style=flat-square&logo=android)](#)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20Local%20%7C%20No%20Cloud%20Required-10B981?style=flat-square)](#)

> **Part of the Jazdot Enterprises Mobile Network Suite** alongside [DotSignal](file:///home/ros/dotsignal) (Cellular & 5G Baseband Telemetry) and [DotBand](file:///home/ros/dotband) (Wi-Fi 6E/7 Spectrum Analyzer).

---

## Executive Overview

**DotLan** is an ad-free, zero-login, privacy-first local network auditor and smart device radar. It solves the number one question asked by homeowners, travelers, and enterprise IT staff: **"Who is on my Wi-Fi, and what are they doing?"**

While competing apps like Fing alienated millions of users by introducing mandatory cloud logins, full-screen ads, and $6.99/month subscriptions—and legacy scanners broke on modern Android because of kernel `/proc/net/arp` restrictions—**DotLan** delivers a sub-second, zero-login, privacy-respecting local network sweep utilizing **modern multi-tier application, transport, and link layer discovery (TCP RST handshakes, IPv6 NDP multicast, mDNS, UPnP, NetBIOS NBNS, and verified RTSP/ONVIF camera probes)**.

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                             DOTLAN DISCOVERY CHASSIS                             │
├───────────────────────┬──────────────────────────┬───────────────────────────────┤
│ mDNS / Bonjour        │ UPnP / SSDP Multicast    │ High-Value IoT Port Radar     │
│ Apple TV, Chromecast, │ Routers, Gateways,       │ RTSP (Port 554), ONVIF (8000) │
│ AirPlay, Printers,    │ Smart Plugs, Media Sinks │ Web Banners (80/443),         │
│ NAS Samba Shares      │ Embedded Edge Workloads  │ Raw Printers (Port 9100)      │
├───────────────────────┴──────────────────────────┴───────────────────────────────┤
│ IPv6 NDP Multicast    │ NetBIOS NBNS (UDP 137)   │ Wi-Fi 7 / 6E Physical RF HUD  │
│ ICMPv6 ff02::1 & mDNS │ Physical MAC Extraction  │ MLO, 320 MHz, 6 GHz, RSSI     │
└──────────────────────────────────────────────────┴───────────────────────────────┘
```

---

## Key Capabilities

1. **Sub-Second Subnet Discovery**: Scans local `/24` subnets (254 addresses) in under 1.0 second via asynchronous bounded non-blocking socket sweeps (`Semaphore(128)`, 120ms timeout) utilizing TCP RST affirmative detection.
2. **Dual-Stack IPv6 NDP Discovery**: Enumerates active IPv6 devices on modern networks via ICMPv6 All-Nodes Multicast (`ff02::1`) and IPv6 mDNS, unifying dual-stack host cards.
3. **Hidden Camera & Video Stream Sentry**: Deeply probes local endpoints with verified RTSP (Port 554) `OPTIONS` handshakes and ONVIF (Port 8000) SOAP discovery—eliminating false alarms and providing essential security for Airbnb guests and hotel travelers.
4. **mDNS & UPnP Service Fingerprinting**: Automatically extracts device names, broadcast services, and hardware profiles via Android `NsdManager` and UDP multicast without needing blocked `/proc/net/arp` kernel tables.
5. **Router UPnP Port-Forwarding Auditor**: Queries router IGD endpoints on-device to retrieve public WAN IP without external cloud dependencies, flagging dangerous external UPnP port mappings.
6. **Wi-Fi 7 / 6E Physical RF Telemetry**: Displays real-time Wi-Fi standard, 320 MHz channel width, 6 GHz band, RSSI (dBm), and Multi-Link Operation (MLO) status.
7. **Multi-Sensory Radar Haptics**: Emits rotary tactile ticks as the radar beam sweeps past active hosts and urgent vibrations upon verifying a video camera stream.
8. **Obsidian Luxury CAD Dark Theme**: 100% ad-free, zero account requirements, zero telemetry uploads.
9. **OCSF v1.3.0 & JSON Export**: Seamlessly exports subnet inventory to enterprise SIEM tools (`dotsec`) and local edge orchestrators (`dotedge`).

---

## Jazdot Organization Visibility & Brand Parity

To maximize corporate visibility for **Jazdot Enterprises**, DotLan mirrors the architecture and aesthetic of **DotSignal**:

* **Signature Animated Logo**: Features the pulsing Jazdot Gold Dot anchored at the central gateway hub of a 360-degree radar sweep (`DotLanAnimatedLogo`).
* **Corporate Header**: Consistent "DOT" + "LAN" emerald/gold typography and the official Jazdot crest logo.
* **"More by Jazdot Enterprises" Drawer**: One-tap cross-navigation between DotSignal, DotBand, and DotLan.
* **Jazdot Enterprise Proof Seals**: Exported subnet audit PDFs carry cryptographic provenance seals (`VERIFIED_SUBNET_AUDIT_SEAL`).
* **Direct Bridge to Enterprise Solutions**: Prominently highlights Jazdot's commercial edge platform: **dotedge** (Edge Computing, K3s Micro-Orchestration & Private Network IoT Isolation).

---

## Directory Structure

```
/home/ros/dotlan/
├── assets/
│   └── logos/
│       ├── dotlan.svg              # Vector brand squircle with radar rings & gold dot
│       └── dotlan_wordmark.svg     # Horizontal wordmark for headers & reports
├── lib/
│   ├── core/
│   │   ├── theme/
│   │   │   └── obsidian_theme.dart # Shared 8pt grid, OLED black palette & luxury tokens
│   │   └── widgets/
│   │       └── dot_lan_animated_logo.dart # Flutter CustomPainter animated radar logo
│   └── main.dart                   # Application entry point & tab navigation
├── scripts/
│   └── build_apk.sh                # Automated Android release build engine
├── tests/                          # Automated unit & conformance test suite
├── pubspec.yaml                    # Flutter project configuration
├── README.md                       # Repository overview & quick start
└── REQUIREMENTS_AND_PLAN.md        # Comprehensive technical requirements & roadmap (v2.1.0)
```

---

## Detailed Specifications

For complete functional specifications, Android API bindings, Google Play launch strategy, and the phase-by-phase development roadmap, see:

👉 **[REQUIREMENTS_AND_PLAN.md](file:///home/ros/dotlan/REQUIREMENTS_AND_PLAN.md)**
