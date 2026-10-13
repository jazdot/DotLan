import 'dart:convert';

/**
 * Categorization of local network endpoints.
 */
enum DeviceCategory {
  gateway,       // Router, AP, Firewall
  camera,        // RTSP, ONVIF, IP Surveillance Camera
  workstation,   // Desktop, Laptop, Server, NAS
  mobile,        // Smartphone, Tablet, Wearable
  iot,           // Smart Plugs, Bulbs, Thermostats, ESP32
  printer,       // IPP, JetDirect, Network Printer
  entertainment, // Smart TV, Apple TV, Chromecast, Sonos
  unknown,       // Generic active IP host
}

/**
 * Representation of an active IP endpoint on the local Wi-Fi subnet.
 */
class LanDevice {
  final String ip;
  final String? ipv6LinkLocal;
  final String? ipv6Global;
  final String? mac;
  final String? hostname;
  final String? vendor;
  final String? model;
  final DeviceCategory category;
  final List<int> openPorts;
  final List<String> detectedServices;
  final double pingLatencyMs;
  final bool isCamera;
  final bool isConfirmedCamera;
  final String? cameraProtocol;
  final int firstSeenMs;
  final int lastSeenMs;
  final bool isNewDevice;
  final String? mdnsName;
  final String? upnpServer;
  final String? netbiosName;
  final bool isGateway;
  final bool isLocalDevice;

  const LanDevice({
    required this.ip,
    this.ipv6LinkLocal,
    this.ipv6Global,
    this.mac,
    this.hostname,
    this.vendor,
    this.model,
    this.category = DeviceCategory.unknown,
    this.openPorts = const [],
    this.detectedServices = const [],
    this.pingLatencyMs = 0.0,
    this.isCamera = false,
    this.isConfirmedCamera = false,
    this.cameraProtocol,
    required this.firstSeenMs,
    required this.lastSeenMs,
    this.isNewDevice = false,
    this.mdnsName,
    this.upnpServer,
    this.netbiosName,
    this.isGateway = false,
    this.isLocalDevice = false,
  });

  String get displayName {
    if (hostname != null && hostname!.isNotEmpty) return hostname!;
    if (mdnsName != null && mdnsName!.isNotEmpty) return mdnsName!;
    if (netbiosName != null && netbiosName!.isNotEmpty) return netbiosName!;
    if (model != null && model!.isNotEmpty) return model!;
    if (isGateway) return 'Default Gateway';
    if (isLocalDevice) return 'This Device';
    return 'Host $ip';
  }

  String get resolvedVendor {
    if (vendor != null && vendor!.isNotEmpty) return vendor!;
    if (isCamera) return 'Surveillance Hardware';
    return 'Unknown Vendor';
  }

  LanDevice copyWith({
    String? ip,
    String? ipv6LinkLocal,
    String? ipv6Global,
    String? mac,
    String? hostname,
    String? vendor,
    String? model,
    DeviceCategory? category,
    List<int>? openPorts,
    List<String>? detectedServices,
    double? pingLatencyMs,
    bool? isCamera,
    bool? isConfirmedCamera,
    String? cameraProtocol,
    int? firstSeenMs,
    int? lastSeenMs,
    bool? isNewDevice,
    String? mdnsName,
    String? upnpServer,
    String? netbiosName,
    bool? isGateway,
    bool? isLocalDevice,
  }) {
    return LanDevice(
      ip: ip ?? this.ip,
      ipv6LinkLocal: ipv6LinkLocal ?? this.ipv6LinkLocal,
      ipv6Global: ipv6Global ?? this.ipv6Global,
      mac: mac ?? this.mac,
      hostname: hostname ?? this.hostname,
      vendor: vendor ?? this.vendor,
      model: model ?? this.model,
      category: category ?? this.category,
      openPorts: openPorts ?? this.openPorts,
      detectedServices: detectedServices ?? this.detectedServices,
      pingLatencyMs: pingLatencyMs ?? this.pingLatencyMs,
      isCamera: isCamera ?? this.isCamera,
      isConfirmedCamera: isConfirmedCamera ?? this.isConfirmedCamera,
      cameraProtocol: cameraProtocol ?? this.cameraProtocol,
      firstSeenMs: firstSeenMs ?? this.firstSeenMs,
      lastSeenMs: lastSeenMs ?? this.lastSeenMs,
      isNewDevice: isNewDevice ?? this.isNewDevice,
      mdnsName: mdnsName ?? this.mdnsName,
      upnpServer: upnpServer ?? this.upnpServer,
      netbiosName: netbiosName ?? this.netbiosName,
      isGateway: isGateway ?? this.isGateway,
      isLocalDevice: isLocalDevice ?? this.isLocalDevice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ip': ip,
      'ipv6_link_local': ipv6LinkLocal,
      'ipv6_global': ipv6Global,
      'mac': mac,
      'hostname': hostname,
      'vendor': vendor,
      'model': model,
      'category': category.name,
      'open_ports': openPorts,
      'detected_services': detectedServices,
      'ping_latency_ms': pingLatencyMs,
      'is_camera': isCamera,
      'is_confirmed_camera': isConfirmedCamera,
      'camera_protocol': cameraProtocol,
      'first_seen_ms': firstSeenMs,
      'last_seen_ms': lastSeenMs,
      'is_new_device': isNewDevice,
      'mdns_name': mdnsName,
      'upnp_server': upnpServer,
      'netbios_name': netbiosName,
      'is_gateway': isGateway,
      'is_local_device': isLocalDevice,
    };
  }

  factory LanDevice.fromMap(Map<String, dynamic> map) {
    return LanDevice(
      ip: map['ip'] as String,
      ipv6LinkLocal: map['ipv6_link_local'] as String?,
      ipv6Global: map['ipv6_global'] as String?,
      mac: map['mac'] as String?,
      hostname: map['hostname'] as String?,
      vendor: map['vendor'] as String?,
      model: map['model'] as String?,
      category: DeviceCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => DeviceCategory.unknown,
      ),
      openPorts: List<int>.from(map['open_ports'] ?? []),
      detectedServices: List<String>.from(map['detected_services'] ?? []),
      pingLatencyMs: (map['ping_latency_ms'] as num?)?.toDouble() ?? 0.0,
      isCamera: map['is_camera'] as bool? ?? false,
      isConfirmedCamera: map['is_confirmed_camera'] as bool? ?? false,
      cameraProtocol: map['camera_protocol'] as String?,
      firstSeenMs: map['first_seen_ms'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      lastSeenMs: map['last_seen_ms'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      isNewDevice: map['is_new_device'] as bool? ?? false,
      mdnsName: map['mdns_name'] as String?,
      upnpServer: map['upnp_server'] as String?,
      netbiosName: map['netbios_name'] as String?,
      isGateway: map['is_gateway'] as bool? ?? false,
      isLocalDevice: map['is_local_device'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory LanDevice.fromJson(String source) => LanDevice.fromMap(jsonDecode(source));
}
