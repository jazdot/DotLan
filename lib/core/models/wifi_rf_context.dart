import 'dart:convert';

/**
 * Wi-Fi 7 / 6E / 5 Physical RF Telemetry & Network Environment Profile.
 */
class WifiRfContext {
  final String ssid;
  final String bssid;
  final String gatewayIp;
  final String localIp;
  final String netmask;
  final int cidrPrefix;
  final String? publicWanIp;
  final bool isDoubleNat;
  final bool isCgnat;
  final String wifiStandard; // e.g. Wi-Fi 7 (802.11be), Wi-Fi 6E (802.11ax), Wi-Fi 5
  final int frequencyMhz;    // e.g. 5975 (6 GHz), 5180 (5 GHz), 2412 (2.4 GHz)
  final int channelWidthMhz; // 20, 40, 80, 160, 320
  final int rssiDbm;         // e.g. -54 dBm
  final int linkSpeedMbps;   // e.g. 2400 Mbps
  final bool isMloActive;    // Wi-Fi 7 Multi-Link Operation
  final bool isVpnActive;
  final bool isCaptivePortal;
  final bool isClientIsolation;
  final String dnsServer;
  final bool isDnsSecure;

  const WifiRfContext({
    this.ssid = 'Local Wi-Fi Network',
    this.bssid = '00:00:00:00:00:00',
    this.gatewayIp = '192.168.1.1',
    this.localIp = '192.168.1.100',
    this.netmask = '255.255.255.0',
    this.cidrPrefix = 24,
    this.publicWanIp,
    this.isDoubleNat = false,
    this.isCgnat = false,
    this.wifiStandard = 'Wi-Fi 6 (802.11ax)',
    this.frequencyMhz = 5240,
    this.channelWidthMhz = 80,
    this.rssiDbm = -58,
    this.linkSpeedMbps = 1200,
    this.isMloActive = false,
    this.isVpnActive = false,
    this.isCaptivePortal = false,
    this.isClientIsolation = false,
    this.dnsServer = '192.168.1.1',
    this.isDnsSecure = true,
  });

  WifiRfContext copyWith({
    String? ssid,
    String? bssid,
    String? gatewayIp,
    String? localIp,
    String? netmask,
    int? cidrPrefix,
    String? publicWanIp,
    bool? isDoubleNat,
    bool? isCgnat,
    String? wifiStandard,
    int? frequencyMhz,
    int? channelWidthMhz,
    int? rssiDbm,
    int? linkSpeedMbps,
    bool? isMloActive,
    bool? isVpnActive,
    bool? isCaptivePortal,
    bool? isClientIsolation,
    String? dnsServer,
    bool? isDnsSecure,
  }) {
    return WifiRfContext(
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      gatewayIp: gatewayIp ?? this.gatewayIp,
      localIp: localIp ?? this.localIp,
      netmask: netmask ?? this.netmask,
      cidrPrefix: cidrPrefix ?? this.cidrPrefix,
      publicWanIp: publicWanIp ?? this.publicWanIp,
      isDoubleNat: isDoubleNat ?? this.isDoubleNat,
      isCgnat: isCgnat ?? this.isCgnat,
      wifiStandard: wifiStandard ?? this.wifiStandard,
      frequencyMhz: frequencyMhz ?? this.frequencyMhz,
      channelWidthMhz: channelWidthMhz ?? this.channelWidthMhz,
      rssiDbm: rssiDbm ?? this.rssiDbm,
      linkSpeedMbps: linkSpeedMbps ?? this.linkSpeedMbps,
      isMloActive: isMloActive ?? this.isMloActive,
      isVpnActive: isVpnActive ?? this.isVpnActive,
      isCaptivePortal: isCaptivePortal ?? this.isCaptivePortal,
      isClientIsolation: isClientIsolation ?? this.isClientIsolation,
      dnsServer: dnsServer ?? this.dnsServer,
      isDnsSecure: isDnsSecure ?? this.isDnsSecure,
    );
  }

  String get frequencyBandDescription {
    if (frequencyMhz >= 5925 && frequencyMhz <= 7125) {
      return '6 GHz (Wi-Fi 6E / 7)';
    } else if (frequencyMhz >= 5000 && frequencyMhz < 5925) {
      return '5 GHz';
    } else if (frequencyMhz >= 2400 && frequencyMhz < 2500) {
      return '2.4 GHz';
    }
    return 'Wi-Fi RF';
  }

  String get signalQualityGrade {
    if (rssiDbm >= -55) return 'Carrier Grade (Excellent)';
    if (rssiDbm >= -68) return 'Stable (Good)';
    if (rssiDbm >= -80) return 'Degraded (Fair)';
    return 'Critical (Poor)';
  }

  Map<String, dynamic> toMap() {
    return {
      'ssid': ssid,
      'bssid': bssid,
      'gateway_ip': gatewayIp,
      'local_ip': localIp,
      'netmask': netmask,
      'cidr_prefix': cidrPrefix,
      'public_wan_ip': publicWanIp,
      'is_double_nat': isDoubleNat,
      'is_cgnat': isCgnat,
      'wifi_standard': wifiStandard,
      'frequency_mhz': frequencyMhz,
      'channel_width_mhz': channelWidthMhz,
      'rssi_dbm': rssiDbm,
      'link_speed_mbps': linkSpeedMbps,
      'is_mlo_active': isMloActive,
      'is_vpn_active': isVpnActive,
      'is_captive_portal': isCaptivePortal,
      'is_client_isolation': isClientIsolation,
      'dns_server': dnsServer,
      'is_dns_secure': isDnsSecure,
    };
  }

  factory WifiRfContext.fromMap(Map<String, dynamic> map) {
    return WifiRfContext(
      ssid: map['ssid'] as String? ?? 'Local Wi-Fi Network',
      bssid: map['bssid'] as String? ?? '00:00:00:00:00:00',
      gatewayIp: map['gateway_ip'] as String? ?? '192.168.1.1',
      localIp: map['local_ip'] as String? ?? '192.168.1.100',
      netmask: map['netmask'] as String? ?? '255.255.255.0',
      cidrPrefix: map['cidr_prefix'] as int? ?? 24,
      publicWanIp: map['public_wan_ip'] as String?,
      isDoubleNat: map['is_double_nat'] as bool? ?? false,
      isCgnat: map['is_cgnat'] as bool? ?? false,
      wifiStandard: map['wifi_standard'] as String? ?? 'Wi-Fi 6 (802.11ax)',
      frequencyMhz: map['frequency_mhz'] as int? ?? 5240,
      channelWidthMhz: map['channel_width_mhz'] as int? ?? 80,
      rssiDbm: map['rssi_dbm'] as int? ?? -58,
      linkSpeedMbps: map['link_speed_mbps'] as int? ?? 1200,
      isMloActive: map['is_mlo_active'] as bool? ?? false,
      isVpnActive: map['is_vpn_active'] as bool? ?? false,
      isCaptivePortal: map['is_captive_portal'] as bool? ?? false,
      isClientIsolation: map['is_client_isolation'] as bool? ?? false,
      dnsServer: map['dns_server'] as String? ?? '192.168.1.1',
      isDnsSecure: map['is_dns_secure'] as bool? ?? true,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory WifiRfContext.fromJson(String source) => WifiRfContext.fromMap(jsonDecode(source));
}
