# DotLan — Technical Requirements, Architecture & Execution Plan

**Document Version:** 2.0.0  
**Target Platform:** Android (API Level 33–36 / Android 13–16), iOS (Network.framework sandbox)  
**Author:** Jazdot Enterprises Architecture Team & Telco/Network SME  
**Status:** Approved for Engineering Implementation (v2.0.0 Perfected)  

---

## 1. Executive Product Charter

### 1.1 Vision & Mission
**DotLan** is an ad-free, zero-login, privacy-first local subnet auditor, smart IoT scanner, and hidden camera radar. It provides instant visibility into every active IP endpoint on the local Wi-Fi subnet without requiring cloud accounts, subscriptions, or invasive permissions.

### 1.2 The Competitor Vacuum & Market Opportunity
* **Fing (10M+ installs)**: Alienated its global user community by imposing mandatory cloud logins, intrusive full-screen video ads, and paywalling basic subnet features behind $6.99/month subscriptions.
* **WiFiman (Ubiquiti)**: High quality and ad-free, but heavily biased toward UniFi network hardware and completely lacks dedicated traveler camera sentry tools or cryptographic audit exports.
* **Legacy Android Scanners**: Broken on Android 11–16 because they still attempt to read `/proc/net/arp`, which Google locked down under non-root SELinux policies.

### 1.3 Core Success Metrics
* **Play Store Velocity**: Top 5 ranking for search queries `who is on my wifi`, `network scanner no ads`, and `hidden camera detector wifi`.
* **Zero Account Adoption**: 100% of functionality accessible instantly on first launch with zero onboarding friction.
* **Conversion to Jazdot Enterprises**: 15%+ of users navigate to the Jazdot Suite drawer, learning about **dotedge** (edge computing, K3s micro-orchestration, and IoT isolation) and **DotSignal** (5G cellular telemetry).

---

## 2. Jazdot Ecosystem Brand Parity

To reinforce the **Jazdot Enterprises** brand, DotLan mirrors the architecture and aesthetic of **DotSignal**:

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                     THE JAZDOT BRAND UNIFORMITY MATRIX                           │
├──────────────────────┬───────────────────────────────────────────────────────────┤
│ Component            │ Implementation in DotLan (Parity with DotSignal)          │
├──────────────────────┼───────────────────────────────────────────────────────────┤
│ Visual Design System │ Obsidian Luxury CAD Theme (`#05070B` OLED background,     │
│                      │ hairline emerald/gold borders, monospace tabular figures).│
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
│ Cross-App Navigation │ "Jazdot Suite" navigation drawer featuring one-tap access │
│                      │ to DotSignal (Cellular 5G) and DotBand (Wi-Fi 6E/7).      │
├──────────────────────┼───────────────────────────────────────────────────────────┤
│ Enterprise Bridge    │ Promotes Jazdot commercial edge infrastructure:           │
│                      │ "Isolate enterprise IoT with Jazdot dotedge & K3s UPF".   │
└──────────────────────┴───────────────────────────────────────────────────────────┘
```

---

## 3. Telco & Protocol SME Analysis (L2, L3, L4, L7 Mechanics)

### 3.1 The Post-Android 10 ARP Reality & Unrooted Layer 3 Solution
* **The Constraint**: Since Android 10, `/proc/net/arp` returns `Permission Denied` to non-root applications. Kernel neighbor MAC addresses cannot be read directly.
* **The TCP RST Duality**:
  * Unreachable IP: Causes socket connection timeout (`ETIMEDOUT` / `EHOSTUNREACH`).
  * Active Host with Closed Port: The host's kernel TCP/IP stack **immediately transmits a TCP RST packet**. In Java/Kotlin, `socket.connect()` throws `ConnectException: Connection refused` in under 2ms.
  * **Conclusive Principle**: `ConnectException: Connection refused` proves that an active IP host exists at that address! DotLan treats `ECONNREFUSED` as a confirmed active device.

### 3.2 Dynamic Netmask & Bounded Subnet Slicing
* Instead of naively hardcoding `/24`, DotLan extracts the true CIDR netmask from `LinkProperties.linkAddresses`.
* If CIDR prefix $< 23$ (e.g. `/16` or `/8` common in hotels, campuses, and enterprise networks):
  * DotLan executes a high-speed `/24` neighborhood sweep around the local host IP.
  * Emits mDNS and SSDP multicast queries to discover active broadcasting devices across the wider subnet.
  * Alerts user with an Enterprise Subnet Badge rather than attempting to open 65,534 simultaneous sockets.

### 3.3 AP Client Isolation (Split-Horizon) Detection
* In guest networks where peer-to-peer communication is blocked by the wireless access point, DotLan detects the absence of any peer response and triggers an educational badge:
  > **AP Client Isolation Active**: Device-to-device communication is blocked by this Wi-Fi network. Other guest devices cannot inspect or connect to your phone.

---

## 4. Multi-Tier Discovery Pipeline

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                   DOTLAN MULTI-TIER DISCOVERY PIPELINE                           │
├──────────────────────────────────────────────────────────────────────────────────────────────────┤
│ TIER 1: ACTIVE IP REACHABILITY (Sub-Second Fast Sweep)                                            │
│ • Bounded coroutines with Semaphore(128) probing ports 80, 443, 445, 139, 22, 8080, 62078.       │
│ • TCP RST (Connection Refused) and TCP Established both register confirmed active host.          │
│ • NetBIOS Name Service (NBNS) UDP 137 status query (RFC 1002) for Windows / SMB hostnames.       │
├──────────────────────────────────────────────────────────────────────────────────────────────────┤
│ TIER 2: mDNS / DNS-SD SERVICE ENUMERATION (RFC 6762 / RFC 6763)                                  │
│ • Multicast DNS query to 224.0.0.251:5353 with WifiManager.MulticastLock held.                   │
│ • Native Android NsdManager with fallback to raw UDP MulticastSocket.                            │
│ • Resolves: Apple TV, AirPlay, Chromecast, Spotify Connect, Printers, Matter/Thread IoT.         │
├──────────────────────────────────────────────────────────────────────────────────────────────────┤
│ TIER 3: SSDP / UPNP DEVICE PROFILING (RFC 2710 / UPnP Device Architecture)                       │
│ • Multicast M-SEARCH to 239.255.255.250:1900.                                                    │
│ • Discovers: Gateway routers, Hue bridges, Sonos players, smart TVs, UPnP media servers.         │
├──────────────────────────────────────────────────────────────────────────────────────────────────┤
│ TIER 4: HIGH-VALUE SERVICE & SURVEILLANCE SENTRY                                                 │
│ • RTSP (Port 554), ONVIF (Port 8000/8899), HTTP Web Banners (80/443/8080).                      │
│ • Multi-stage verification ladder before flagging video camera alerts.                           │
└──────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Functional Requirements (FR)

### Subnet Discovery & Host Inventory
* **FR-01 (Sub-Second Subnet Sweep)**: Scan all 254 host addresses on a `/24` subnet concurrently in under 1.0 second using bounded asynchronous socket handshakes (`Semaphore(128)`, 120ms timeout).
* **FR-02 (TCP RST Active Host Detection)**: Recognize both `TCP Established` and `TCP RST (Connection Refused)` as affirmative indicators of an active IP host.
* **FR-03 (mDNS Device Discovery)**: Enumerate Multicast DNS services on `224.0.0.251:5353`, resolving human-readable names (e.g. *"Living Room Apple TV"*, *"Office LaserJet"*).
* **FR-04 (SSDP / UPnP Gateway & Media Discovery)**: Transmit `M-SEARCH` multicast datagrams to `239.255.255.250:1900`, parsing XML device descriptions for manufacturer, model, and friendly names.
* **FR-05 (NetBIOS NBNS Resolution)**: Send UDP port 137 Node Status queries to resolve legacy Windows, Linux Samba, and NAS hostnames.
* **FR-06 (Dynamic CIDR Slicing)**: Detect netmask prefix from `LinkProperties`; protect against file descriptor exhaustion on enterprise `/16` or `/8` networks.

### Security, Camera Sentry & Gateway Auditing
* **FR-07 (Hidden Camera & Video Stream Sentry)**: Automatically scan for RTSP (Port 554) and ONVIF (Port 8000/8899) endpoints. Execute RTSP `OPTIONS * RTSP/1.0` and ONVIF SOAP handshakes to verify genuine video feeds and eliminate false positives.
* **FR-08 (Zero-Cloud WAN IP Discovery)**: Query router UPnP IGD `WANIPConnection:1` action `GetExternalIPAddress` to retrieve public WAN IP on-device with zero external cloud dependencies.
* **FR-09 (UPnP Port-Forwarding Vulnerability Audit)**: Enumerate router port mappings via `GetGenericPortMappingEntry`, flagging exposed external WAN ports (RDP 3389, Torrent, Plex, CCTV).
* **FR-10 (Double-NAT & CGNAT Detection)**: Compare router WAN IP against RFC 1918 and RFC 6598 (`100.64.0.0/10`) to identify ISP Carrier-Grade NAT and Double-NAT topologies.
* **FR-11 (Targeted Port Profiler)**: On explicit user demand, scan top 20 ports on any selected host (SSH 22, Telnet 23, DNS 53, HTTP 80, SMB 445, RTSP 554, etc.).
* **FR-12 (New Device Join Alert)**: Cache known device fingerprints in local storage; trigger instant notification when an unrecognized IP joins the subnet.

### Export & Organization Telemetry
* **FR-13 (OCSF v1.3.0 Serialization)**: Export subnet host inventories as standardized Open Cybersecurity Schema Framework Class 4001 (Network Activity) JSONL events.
* **FR-14 (Jazdot PDF Audit Certificate)**: Generate branded executive PDF network audit certificates with cryptographic verification seals (`VERIFIED_SUBNET_AUDIT_SEAL`), Wi-Fi RF details, and camera scan results.
* **FR-15 (JSON & CSV Data Dumps)**: One-tap export of active IP addresses, hostnames, response latencies, and open services.
* **FR-16 (Jazdot Suite Navigation)**: Cross-navigation drawer providing direct links to DotSignal (Cellular 5G) and DotBand (Wi-Fi 6E/7).

---

## 6. Non-Functional & Security Requirements (NFR)

* **NFR-01 (100% Non-Root Compliance)**: Strictly zero root or privileged signature permissions required.
* **NFR-02 (Zero Cloud Telemetry)**: All subnet scans, mDNS parsing, and PDF reports execute completely on-device. Zero telemetry uploads.
* **NFR-03 (Sub-Second Scan Velocity)**: Full `/24` subnet sweep completed in $< 1.0$ second on standard 802.11ac/ax/be Wi-Fi.
* **NFR-04 (File Descriptor Guard)**: Bound concurrent socket connections to $\le 128$ to prevent Linux `EMFILE` exhaustion.
* **NFR-05 (MulticastLock Lifecycle)**: Properly acquire and release `WifiManager.MulticastLock` on Android to prevent Wi-Fi NIC multicast dropping without battery drain.
* **NFR-06 (iOS Local Network Compliance)**: Gracefully handle `NSLocalNetworkUsageDescription` permissions; support fallback Bonjour `NWBrowser` discovery.
* **NFR-07 (Google Play Store Compliance)**: Adheres strictly to Google Play Developer Policies (`INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, `CHANGE_WIFI_MULTICAST_STATE`).

---

## 7. UI/UX Architecture & Screen Flow

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                             DOTLAN 4-TAB ARCHITECTURE                            │
├───────────────────┬───────────────────┬───────────────────┬──────────────────────┤
│ TAB 1: RADAR      │ TAB 2: INVENTORY  │ TAB 3: SENTRY     │ TAB 4: DIAGNOSTICS   │
│ Interactive 360°  │ Categorized host  │ Dedicated Airbnb  │ UPnP port forwards,  │
│ topology canvas   │ cards with vendor │ hidden camera &   │ WAN IP, ping jitter, │
│ plotted by latency│ badges & ports    │ RTSP/ONVIF sentry │ DNS hijacking audit  │
└───────────────────┴───────────────────┴───────────────────┴──────────────────────┘
```

1. **Tab 1: RADAR (Interactive Topology Canvas)**:
   - Central pulsing Jazdot Gold Dot representing the local observer/gateway.
   - Discovered devices plotted radially by response latency (ms).
   - Rotating radar sweep beam with trailing emerald gradient.
   - Interactive blip touch selection opening quick-inspect modal.
2. **Tab 2: INVENTORY (Device List & Port Profiler)**:
   - Filter chips: All, Cameras, Gateways, Compute, Mobile, Smart IoT.
   - Host cards displaying IP, Hostname, Detected Services (`mDNS`, `UPnP`, `NBNS`, `RTSP`), and Ping Latency.
   - One-tap action: "Targeted Port Scan".
3. **Tab 3: CAMERA SENTRY (Traveler Privacy Guard)**:
   - Dedicated Airbnb & Hotel room sweep mode.
   - High-contrast visual indicators: "Zero Video Streams Detected" vs "Confirmed RTSP Video Stream".
   - One-tap export: "Traveler Safety Audit Certificate".
4. **Tab 4: DIAGNOSTICS (Gateway & Security Health)**:
   - Router model, firmware, and UPnP IGD status.
   - True on-device WAN IP and Double-NAT / CGNAT classification.
   - Exposed UPnP Port Forwarding Vulnerability Table.
   - Gateway ping jitter and DNS integrity verification.

---

## 8. Implementation Roadmap

```
┌────────────────────────────────────────────────────────────────────────┐
│ PHASE 1: Subnet Socket Sweep & Discovery Engine (Days 1–3)             │
│ • Bounded coroutines with Semaphore(128) and TCP RST detection         │
│ • Dynamic CIDR netmask parsing and NetBIOS NBNS UDP 137 prober         │
├────────────────────────────────────────────────────────────────────────┤
│ PHASE 2: mDNS & UPnP Service Fingerprinting (Days 4–6)                 │
│ • MulticastLock management on Android                                  │
│ • mDNS DNS-SD query engine and SSDP M-SEARCH parser                    │
├────────────────────────────────────────────────────────────────────────┤
│ PHASE 3: Camera Sentry & Router UPnP Auditor (Days 7–9)                │
│ • RTSP OPTIONS & ONVIF SOAP handshake verification                     │
│ • UPnP IGD WAN IP and GetGenericPortMappingEntry auditor               │
├────────────────────────────────────────────────────────────────────────┤
│ PHASE 4: UI/UX Canvas & Obsidian Design Integration (Days 10–12)       │
│ • 360° Topology Radar CustomPainter with 120fps stutter-free canvas    │
│ • 4-tab navigation, Inventory cards, and Jazdot Suite drawer           │
├────────────────────────────────────────────────────────────────────────┤
│ PHASE 5: Enterprise Forensics, OCSF v1.3.0 & Production APK (13–14)    │
│ • OCSF Class 4001 JSONL exporter & PDF Audit Report Generator          │
│ • Full test suite and release build verification                       │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Risk Analysis & Mitigation Matrix

| Risk Factor | Probability | Impact | Mitigation Strategy |
| :--- | :--- | :--- | :--- |
| **Silent Hosts (Firewall Drops)** | High | Medium | Combine TCP sweeps across 7 key ports with NetBIOS UDP 137 queries, mDNS broadcasts, and treat TCP RST as affirmative host alive indicator. |
| **Enterprise /16 Subnet Overload** | Medium | High | Dynamically calculate CIDR prefix. Slice /16 into immediate /24 neighborhood + multicast discovery; require explicit user confirmation for broader sweeps. |
| **Android Multicast Dropping** | High | High | Explicitly acquire `WifiManager.MulticastLock` before dispatching mDNS or SSDP queries; release immediately upon scan completion. |
| **File Descriptor Exhaustion (EMFILE)** | Medium | High | Constrain maximum concurrent active sockets to $\le 128$ via `Semaphore`. |
| **Camera Sentry False Positives** | High | High | Strictly require RTSP `OPTIONS * RTSP/1.0` or ONVIF XML handshake verification before flagging confirmed camera alerts. |
| **iOS Local Network Permission Rejection** | Medium | High | Display Obsidian pre-permission educational banner before triggering first local socket probe. |

---

*Certified by Jazdot Enterprises Architecture Board — DotLan Engineering Specifications v2.0.0*
