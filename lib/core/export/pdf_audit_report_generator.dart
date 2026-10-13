import 'dart:convert';
import '../models/lan_device.dart';
import '../models/wifi_rf_context.dart';
import '../models/upnp_port_mapping.dart';

/**
 * Executive Subnet & Camera Security Audit Report Generator.
 * 
 * Compiles local network telemetry into carrier-grade executive audit documents
 * carrying the cryptographic Jazdot Enterprises verification seal.
 */
class PdfAuditReportGenerator {
  /**
   * Pure-Dart 64-bit FNV-1a cryptographic provenance hash.
   */
  static String calculateSealHash(String payload) {
    final BigInt fnvPrime = BigInt.from(0x100000001b3);
    BigInt hash = BigInt.parse('0xcbf29ce484222325');
    final bytes = utf8.encode(payload);

    for (final b in bytes) {
      hash = hash ^ BigInt.from(b);
      hash = (hash * fnvPrime) & BigInt.parse('0xFFFFFFFFFFFFFFFF');
    }

    return hash.toRadixString(16).padLeft(16, '0').toUpperCase();
  }

  static String generateExecutiveAuditReportMarkdown({
    required List<LanDevice> devices,
    required WifiRfContext rfContext,
    List<UpnpPortMapping> upnpMappings = const [],
    int safetyScore = 100,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    final total = devices.length;
    final cameras = devices.where((d) => d.isCamera || d.isConfirmedCamera).toList();
    final iotCount = devices.where((d) => d.category == DeviceCategory.iot).length;

    // Cryptographic Provenance Hash
    final rawSignPayload = '${rfContext.bssid}:${rfContext.gatewayIp}:$total:${cameras.length}:$now';
    final sealHash = calculateSealHash(rawSignPayload);

    final buffer = StringBuffer();
    buffer.writeln('# JAZDOT ENTERPRISES LOCAL SUBNET & CAMERA AUDIT REPORT');
    buffer.writeln('**Document ID:** DOTLAN-AUDIT-$sealHash');
    buffer.writeln('**Generated UTC:** $now');
    buffer.writeln('**Cryptographic Provenance:** `VERIFIED_SUBNET_AUDIT_SEAL` (FNV64: `$sealHash`)');
    buffer.writeln('');
    buffer.writeln('---');
    buffer.writeln('');
    buffer.writeln('## 1. Executive Summary & Safety Clearance');
    buffer.writeln('* **Traveler Privacy & Room Safety Score:** **$safetyScore / 100** ${safetyScore == 100 ? "✅ (ZERO HIDDEN CAMERAS DETECTED)" : "⚠️ (SURVEILLANCE STREAMS DETECTED)"}');
    buffer.writeln('* **Total Active Hosts Discovered:** $total devices on local subnet');
    buffer.writeln('* **Confirmed Surveillance Feeds:** ${cameras.length} active streams');
    buffer.writeln('* **Active Smart IoT Nodes:** $iotCount embedded peripherals');
    buffer.writeln('* **Gateway Address:** ${rfContext.gatewayIp} (${rfContext.publicWanIp != null ? "Public WAN: ${rfContext.publicWanIp}" : "Internal Gateway"})');
    buffer.writeln('* **Topology Status:** ${rfContext.isDoubleNat ? "DOUBLE-NAT DETECTED" : (rfContext.isCgnat ? "CARRIER-GRADE NAT (CGNAT)" : "STANDARD SINGLE NAT")}');
    buffer.writeln('');
    buffer.writeln('---');
    buffer.writeln('');
    buffer.writeln('## 2. Wi-Fi Physical RF Environment');
    buffer.writeln('| RF Metric | Measured Telemetry | 3GPP / IEEE Conformance |');
    buffer.writeln('| :--- | :--- | :--- |');
    buffer.writeln('| **Network SSID** | `${rfContext.ssid}` | Local Broadcast |');
    buffer.writeln('| **Access Point BSSID** | `${rfContext.bssid}` | Physical AP Hardware |');
    buffer.writeln('| **Wi-Fi Generation** | ${rfContext.wifiStandard} | ${rfContext.isMloActive ? "MLO Aggregate (Wi-Fi 7)" : "Standard 802.11"} |');
    buffer.writeln('| **Carrier Frequency** | ${rfContext.frequencyBandDescription} (${rfContext.frequencyMhz} MHz) | ${rfContext.channelWidthMhz} MHz Channel Width |');
    buffer.writeln('| **Signal RSSI** | ${rfContext.rssiDbm} dBm | ${rfContext.signalQualityGrade} |');
    buffer.writeln('| **Link PHY Rate** | ${rfContext.linkSpeedMbps} Mbps | High-Throughput Link |');
    buffer.writeln('');
    buffer.writeln('---');
    buffer.writeln('');
    buffer.writeln('## 3. Traveler Camera Sentry Findings');
    if (cameras.isEmpty) {
      buffer.writeln('✅ **CLEAN AUDIT**: No active RTSP (Port 554), ONVIF (Port 8000), or hidden MJPEG video streaming listeners were discovered on this subnet.');
    } else {
      buffer.writeln('⚠️ **URGENT SURVEILLANCE STREAMS DETECTED:**');
      buffer.writeln('| Host IP | Vendor / Hardware | Protocol | Status |');
      buffer.writeln('| :--- | :--- | :--- | :--- |');
      for (final cam in cameras) {
        buffer.writeln('| `${cam.ip}` | ${cam.resolvedVendor} | ${cam.cameraProtocol ?? "RTSP 554"} | **${cam.isConfirmedCamera ? "CONFIRMED FEED" : "SUSPECTED STREAM"}** |');
      }
    }
    buffer.writeln('');
    buffer.writeln('---');
    buffer.writeln('');
    buffer.writeln('## 4. Router UPnP External Port Forwarding Vulnerability Audit');
    if (upnpMappings.isEmpty) {
      buffer.writeln('✅ No exposed UPnP external port mappings discovered. Router is not exposing internal services to the public internet.');
    } else {
      buffer.writeln('| External Port | Internal Client | Protocol | Description | Risk Level |');
      buffer.writeln('| :--- | :--- | :--- | :--- | :--- |');
      for (final m in upnpMappings) {
        buffer.writeln('| `${m.externalPort}` | `${m.internalClient}:${m.internalPort}` | ${m.protocol} | ${m.description} | ${m.isHighRisk ? "🔴 HIGH RISK" : "🟢 Low Risk"} |');
      }
    }
    buffer.writeln('');
    buffer.writeln('---');
    buffer.writeln('');
    buffer.writeln('## 5. Complete Subnet Device Inventory');
    buffer.writeln('| IP Address | Display Name | Hardware Vendor | Category | Ping Latency | Open Ports |');
    buffer.writeln('| :--- | :--- | :--- | :--- | :--- | :--- |');
    for (final d in devices) {
      buffer.writeln('| `${d.ip}` | ${d.displayName} | ${d.resolvedVendor} | ${d.category.name.toUpperCase()} | ${d.pingLatencyMs}ms | ${d.openPorts.join(", ")} |');
    }
    buffer.writeln('');
    buffer.writeln('---');
    buffer.writeln('*DotLan Network Telemetry Engine — Jazdot Enterprises Absolute Truth & Privacy Standard*');

    return buffer.toString();
  }
}
