import 'dart:convert';
import '../models/lan_device.dart';
import '../models/wifi_rf_context.dart';

/**
 * Open Cybersecurity Schema Framework (OCSF) v1.3.0 Exporter.
 * 
 * Formats local subnet discoveries into standardized Class 4001 (Network Activity)
 * events for direct ingestion into `dotsec` and enterprise SIEM pipelines.
 */
class OcsfExporter {
  static Map<String, dynamic> createNetworkActivityEvent({
    required LanDevice device,
    required WifiRfContext rfContext,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();

    return {
      'class_uid': 4001, // Network Activity
      'category_uid': 4, // Network Activity Category
      'activity_id': 1,  // Discover / Inventory
      'severity_id': device.isConfirmedCamera ? 4 : (device.isCamera ? 3 : 1),
      'time': device.lastSeenMs,
      'metadata': {
        'version': '1.3.0',
        'product': {
          'name': 'DotLan',
          'vendor_name': 'Jazdot Enterprises',
          'version': '1.0.0',
        },
        'extension': {
          'name': 'lan_subnet_telemetry',
          'version': '2.1.0',
        },
        'logged_time': now,
      },
      'network_endpoint': {
        'ip': device.ip,
        'mac': device.mac,
        'hostname': device.hostname ?? device.displayName,
        'category': device.category.name,
        'vendor': device.resolvedVendor,
        'ports': device.openPorts,
        'services': device.detectedServices,
        'latency_ms': device.pingLatencyMs,
      },
      'wifi_rf_telemetry': {
        'ssid': rfContext.ssid,
        'bssid': rfContext.bssid,
        'gateway_ip': rfContext.gatewayIp,
        'channel_width_mhz': rfContext.channelWidthMhz,
        'frequency_mhz': rfContext.frequencyMhz,
        'wifi_standard': rfContext.wifiStandard,
        'rssi_dbm': rfContext.rssiDbm,
        'mlo_active': rfContext.isMloActive,
      },
      'security_analysis': {
        'is_camera': device.isCamera,
        'is_confirmed_camera': device.isConfirmedCamera,
        'camera_protocol': device.cameraProtocol,
        'verification_source': 'VERIFIED_SUBNET_AUDIT_SEAL',
      },
    };
  }

  static String exportOcsfJsonl({
    required List<LanDevice> devices,
    required WifiRfContext rfContext,
  }) {
    final buffer = StringBuffer();
    for (final device in devices) {
      final event = createNetworkActivityEvent(device: device, rfContext: rfContext);
      buffer.writeln(jsonEncode(event));
    }
    return buffer.toString();
  }
}
