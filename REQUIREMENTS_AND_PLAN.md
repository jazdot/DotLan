# DotLan — Technical Requirements, Architecture & Execution Plan

**Document Version:** 1.0.0  
**Target Platform:** Android (API Level 33–36 / Android 13–16), iOS (Network.framework sandbox)  
**Author:** Jazdot Enterprises Architecture Team  
**Status:** Approved for Engineering Implementation  

---

## 1. Executive Product Charter

### 1.1 Vision & Mission
**DotLan** is an ad-free, local network scanner, smart device auditor, and camera radar. It provides instant visibility into every active IP endpoint on the local subnet without requiring cloud accounts, subscriptions, or invasive permissions.

### 1.2 Core Success Metrics
* **Play Store Velocity**: Top 5 ranking for search queries `who is on my wifi`, `network scanner no ads`, and `hidden camera detector wifi`.
* **Zero Account Adoption**: 100% of functionality accessible instantly on first launch with zero onboarding friction.
* **Conversion to Jazdot Enterprises**: 15%+ of users navigate to the Jazdot Suite drawer, learning about **dotedge** (edge computing and on-premises IoT isolation).

---

## 2. Jazdot Ecosystem Similarity & Organization Visibility Blueprint

To reinforce the **Jazdot Enterprises** brand, DotLan mirrors the architecture and aesthetic of **DotSignal**:

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                     THE JAZDOT BRAND UNIFORMITY MATRIX                           │
├──────────────────────┬───────────────────────────────────────────────────────────┤
│ Component            │ Implementation in DotLan (Parity with DotSignal)          │
├──────────────────────┼───────────────────────────────────────────────────────────┤
│ Visual Design System │ Obsidian Luxury CAD Theme (`#05070B` OLED background,     │
│                      │ hairline emerald/gold borders, monospace figures).        │
├──────────────────────┼───────────────────────────────────────────────────────────┤
│ Signature Brand Mark │ `DotLanAnimatedLogo` featuring the pulsing Jazdot Gold    │
│                      │ Dot anchored at the center of an emerald radar sweep.     │
├──────────────────────┼───────────────────────────────────────────────────────────┤
│ Top App Bar Wordmark │ Unified "DOT" (White 900) + "LAN" (Emerald 700) layout    │
│                      │ with the official Jazdot crest logo.                      │
├──────────────────────┼───────────────────────────────────────────────────────────┤
│ Telemetry Standard   │ Emits OCSF v1.3.0 Class 4001 (Network Activity) JSONL      │
│                      │ events, directly ingestible by `dotsec` and `dotedge`.    │
├──────────────────────┼───────────────────────────────────────────────────────────┤
│ Verification Seals   │ Exported PDF subnet audits carry cryptographic seals:     │
│                      │ `VERIFIED_SUBNET_AUDIT_SEAL` & `JAZDOT_SEAL_V2`.          │
├──────────────────────┼───────────────────────────────────────────────────────────┤
│ Cross-App Navigation │ "Jazdot Suite" navigation drawer featuring one-tap access  │
│                      │ to [DotSignal](file:///home/ros/dotsignal) and [DotBand](file:///home/ros/dotband).             │
├──────────────────────┼───────────────────────────────────────────────────────────┤
│ Enterprise Bridge    │ Promotes Jazdot commercial edge infrastructure:           │
│                      │ "Isolate enterprise IoT with Jazdot dotedge & K3s UPF".   │
└──────────────────────┴───────────────────────────────────────────────────────────┘
```

---

## 3. Market Problem & Technical Bottleneck Handled

### 3.1 The Competitor Vacuum
* **Fing (10M+ downloads)**: Alienated its loyal community by forcing mandatory cloud logins, inserting full-screen ads, and paywalling basic subnet features behind $6.99/month subscriptions.
* **Legacy Scanners**: Many older utilities crash on Android 11–15 because they still try to parse `/proc/net/arp`, which Google locked down.

### 3.2 The Android 10+ ARP Bottleneck (Handled Legally & Accurately)
* **The Reality**: Starting with Android 10, `/proc/net/arp` returns `Permission Denied` to non-root applications. Apps **cannot read neighbor MAC addresses** directly from the kernel table.
* **How DotLan Solves This**:
  Instead of failing or displaying fake randomized MAC addresses, DotLan identifies devices via **Application-Layer Service Discovery**:
  1. **mDNS / DNS-SD** via Android `NsdManager` (discovers hostnames, device types, and broadcast services like `_airplay._tcp`, `_googlecast._tcp`, `_ipp._tcp`).
  2. **UPnP / SSDP Multicast** over UDP port 1900 (discovers router models, smart bulbs, smart plugs, media servers).
  3. **High-Value IoT Service Probing** (identifies RTSP video streams on Port 554, ONVIF camera APIs on Port 8000, and HTTP administration interfaces).

---

## 4. Functional Requirements (FR)

### Subnet Discovery & Fingerprinting
* **FR-01 (Sub-Second Subnet Sweep)**: Scan all 254 host addresses on the local `/24` subnet concurrently in under 1.5 seconds using non-blocking asynchronous socket handshakes.
* **FR-02 (mDNS Device Discovery)**: Enumerate all Multicast DNS services on the local link using Android's native `NsdManager`, mapping human-readable names (e.g. *"Living Room Apple TV"*, *"Office LaserJet"*).
* **FR-03 (UPnP / SSDP Gateway Discovery)**: Send M-SEARCH UDP multicast datagrams to `239.255.255.250:1900`, parsing XML device descriptions for gateway models and manufacturer profiles.
* **FR-04 (Hidden Spy Camera Sentry)**: Automatically probe active IP hosts for open video streaming ports: RTSP (Port 554), ONVIF (Port 8000 / 8899), and MJPEG HTTP streams. Display an urgent badge: **"LOCAL VIDEO CAMERA DETECTED"**.
* **FR-05 (UPnP Port-Forwarding Audit)**: Query the default gateway router via WANIPConnection UPnP actions to list all external ports exposed to the public internet.

### Network Diagnostics & Security
* **FR-06 (Gateway Ping & Jitter)**: Measure roundtrip latency to the local default gateway to isolate Wi-Fi congestion from ISP backhaul latency.
* **FR-07 (Local Port Profiler)**: Conduct targeted port scans on any selected device across the top 20 most common service ports (SSH 22, Telnet 23, DNS 53, HTTP 80, SMB 445, RTSP 554, etc.).
* **FR-08 (New Device Join Alert)**: Cache known device IPs in local SQLite storage; trigger a local alert whenever a completely new, unrecognized device joins the local network.

### Export & Organization Telemetry
* **FR-09 (OCSF v1.3.0 Serialization)**: Export subnet host inventories as standardized Open Cybersecurity Schema Framework Class 4001 events.
* **FR-10 (Jazdot PDF Audit Certificate)**: Generate branded PDF network audit certificates with Jazdot proof seals, highlighting open camera feeds and vulnerable UPnP forwards.
* **FR-11 (JSON / CSV Subnet Dump)**: One-tap export of active IP addresses, hostnames, and detected services.
* **FR-12 (Enterprise Cloud Uplink)**: Optional sync to Jazdot `dotedge` edge nodes for automated IoT device discovery on industrial factory networks.

---

## 5. Non-Functional & Security Requirements (NFR)

* **NFR-01 (100% Non-Root Compliance)**: Strictly zero root or privileged signature permissions required.
* **NFR-02 (Zero Cloud Telemetry)**: All subnet scans, mDNS parsing, and PDF reports execute completely on-device. No data is ever sent to external cloud servers.
* **NFR-03 (Sub-2s Scan Velocity)**: Full `/24` subnet scan must finish in under 2.0 seconds on standard 802.11ac/ax Wi-Fi.
* **NFR-04 (Battery & Network Courtesy)**: Limit socket connect timeouts to 150ms per probe to prevent network congestion or battery drain.
* **NFR-05 (Google Play Store Compliance)**: Adheres strictly to the Google Play Developer Policy; requires only `INTERNET`, `ACCESS_NETWORK_STATE`, and `ACCESS_WIFI_STATE`.

---

## 6. Technical Architecture & Discovery Engine

```
┌────────────────────────────────────────────────────────────────────────┐
│                         DOTLAN DISCOVERY PIPELINE                      │
├────────────────────────────────────────────────────────────────────────┤
│ 1. Subnet Identification                                               │
│    • Query WifiManager.dhcpInfo ──► Extract IP (e.g. 192.168.1.45)     │
│    • Extract Netmask (255.255.255.0) ──► Calculate Range (1–254)       │
│                                  │                                     │
│ 2. Concurrent Asynchronous Sweep (Kotlin Coroutines)                   │
│    • Dispatch 254 non-blocking TCP socket probes (Ports 80, 443, 554)  │
│    • Timeout: 120ms per socket ──► Aggregate responding IP hosts       │
│                                  │                                     │
│ 3. Service Fingerprinting                                              │
│    • Android NsdManager ────────► mDNS Bonjour Hostname Resolution     │
│    • MulticastSocket (UDP 1900) ─► SSDP UPnP XML Device Descriptions   │
│    • RTSP Port 554 Probe ───────► Hidden Camera Sentry Classification  │
│                                  │                                     │
│ 4. Reactive UI & State Management (Flutter BLoC)                       │
│    • SubnetInventoryCubit ──────► Stream discovered hosts to UI        │
│    • TopologyRadarPainter ──────► Render interactive 360° radar canvas │
└────────────────────────────────────────────────────────────────────────┘
```

### 6.1 Kotlin Asynchronous Socket Sweep Implementation
```kotlin
suspend fun scanSubnet(baseIp: String, onHostFound: (String) -> Unit) = coroutineScope {
    val commonPorts = intArrayOf(80, 443, 554, 8080)
    for (i in 1..254) {
        val targetIp = "$baseIp.$i"
        launch(Dispatchers.IO) {
            for (port in commonPorts) {
                try {
                    Socket().use { socket ->
                        socket.connect(InetSocketAddress(targetIp, port), 120)
                        onHostFound(targetIp)
                        return@launch
                    }
                } catch (_: Exception) {}
            }
        }
    }
}
```

---

## 7. UI/UX Architecture & Screen Flow

1. **Tab 1: RADAR (Interactive Topology Canvas)**:
   - Central pulsing Jazdot Gold Dot representing the device/observer.
   - Discovered devices plotted radially by response latency (ms).
   - Distinct emerald badges for cameras, routers, and workstations.
2. **Tab 2: INVENTORY (Device List)**:
   - Clean card per host displaying: IP, Hostname, Detected Services (`mDNS`, `UPnP`, `RTSP`), Latency.
   - Quick action: "Inspect Ports".
3. **Tab 3: CAMERA SENTRY (Traveler Privacy Guard)**:
   - Dedicated Airbnb/Hotel mode scanning exclusively for hidden RTSP/ONVIF streaming feeds.
4. **Tab 4: DIAGNOSTICS (Gateway & DNS Health)**:
   - Gateway ping jitter, external WAN IP lookup, and DNS hijack check.

---

## 8. Phased Development Roadmap

```
┌────────────────────────────────────────────────────────────────────────┐
│ PHASE 1: Native Subnet & Socket Sweep Engine (Days 1–3)                │
│ • Kotlin coroutine /24 IP prober with 120ms timeout                    │
│ • Flutter MethodChannel & EventChannel bridge                          │
├────────────────────────────────────────────────────────────────────────┤
│ PHASE 2: mDNS & UPnP Service Fingerprinting (Days 4–6)                 │
│ • Android NsdManager integration for Bonjour discovery                │
│ • UDP 1900 SSDP multicast query engine                                 │
├────────────────────────────────────────────────────────────────────────┤
│ PHASE 3: Camera Sentry & Port Profiler (Days 7–9)                      │
│ • Port 554/8000 streaming probe and camera classification badge        │
│ • Multi-port targeted scanner for selected hosts                       │
├────────────────────────────────────────────────────────────────────────┤
│ PHASE 4: Jazdot Brand & Export Architecture (Days 10–12)               │
│ • DotLanAnimatedLogo, ObsidianTheme, and Jazdot Suite drawer           │
│ • OCSF v1.3.0 exporter, JSON/CSV dump, and PDF audit generator         │
├────────────────────────────────────────────────────────────────────────┤
│ PHASE 5: Hardening & Google Play Submission (Days 13–14)               │
│ • Performance optimization on 500+ host enterprise networks           │
│ • Store assets, screenshots, and privacy policy publication            │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Google Play Store Launch & SEO Strategy

* **App Title**: `DotLan: Wi-Fi Scanner & Cam Radar`
* **Subtitle**: `Ad-free network scanner, who is on my Wi-Fi & hidden camera detector.`
* **Keywords**: `who is on my wifi`, `network scanner no ads`, `hidden camera detector wifi`, `local ip scanner`, `upnp scanner`, `iot device finder`.
* **Screenshot Value Props**:
  1. *"Who is using your Wi-Fi? Discovered in under 2 seconds."*
  2. *"100% Ad-Free. Zero accounts. 100% on-device privacy."*
  3. *"Detect hidden cameras & video streams in Airbnb rentals."*
  4. *"Audit router port-forwarding and UPnP security risks."*

---

## 10. Risk Analysis & Mitigation Matrix

| Risk Factor | Probability | Impact | Mitigation Strategy |
| :--- | :--- | :--- | :--- |
| **Silent Hosts (No Open Ports)** | Medium | Medium | Propose ping packets (`InetAddress.isReachable()`) combined with mDNS multicast queries to discover devices that do not listen on HTTP/RTSP. |
| **Wi-Fi Client Isolation (Guest Networks)**| High | Low | If client isolation is active on the router, display clear notification: *"Client isolation detected on this Wi-Fi network. Device-to-device communication is blocked by the router."* |
| **Antivirus Port-Scan False Positives** | Low | Low | Keep probe rates reasonable; limit targeted scans to top 20 ports only upon explicit user tap. |
| **Play Store Policy Compliance** | Low | Low | Zero VPNs, zero root requirements, standard networking permissions only (`INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`). |
