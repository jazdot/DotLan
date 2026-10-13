import 'dart:convert';

/**
 * Representation of a router UPnP IGD public port-forwarding entry.
 */
class UpnpPortMapping {
  final int externalPort;
  final int internalPort;
  final String internalClient;
  final String protocol; // TCP or UDP
  final String description;
  final bool enabled;
  final int leaseDuration;

  const UpnpPortMapping({
    required this.externalPort,
    required this.internalPort,
    required this.internalClient,
    required this.protocol,
    required this.description,
    this.enabled = true,
    this.leaseDuration = 0,
  });

  bool get isHighRisk {
    // Dangerous ports exposed to public WAN
    final p = externalPort;
    return p == 3389 || // RDP
           p == 22 ||   // SSH
           p == 23 ||   // Telnet
           p == 445 ||  // SMB
           p == 554 ||  // RTSP
           p == 8000 || // Camera/Dev
           p == 80 ||   // Web Admin
           p == 443;
  }

  Map<String, dynamic> toMap() {
    return {
      'external_port': externalPort,
      'internal_port': internalPort,
      'internal_client': internalClient,
      'protocol': protocol,
      'description': description,
      'enabled': enabled,
      'lease_duration': leaseDuration,
      'is_high_risk': isHighRisk,
    };
  }

  factory UpnpPortMapping.fromMap(Map<String, dynamic> map) {
    return UpnpPortMapping(
      externalPort: map['external_port'] as int,
      internalPort: map['internal_port'] as int,
      internalClient: map['internal_client'] as String,
      protocol: map['protocol'] as String? ?? 'TCP',
      description: map['description'] as String? ?? 'UPnP Mapping',
      enabled: map['enabled'] as bool? ?? true,
      leaseDuration: map['lease_duration'] as int? ?? 0,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory UpnpPortMapping.fromJson(String source) => UpnpPortMapping.fromMap(jsonDecode(source));
}
