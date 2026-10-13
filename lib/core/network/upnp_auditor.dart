import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/upnp_port_mapping.dart';
import 'subnet_calculator.dart';

/**
 * Result of an executive router UPnP IGD vulnerability inspection.
 */
class UpnpAuditReport {
  final String gatewayIp;
  final bool isUpnpEnabled;
  final String? externalWanIp;
  final bool isDoubleNat;
  final bool isCgnat;
  final List<UpnpPortMapping> portMappings;
  final int highRiskCount;
  final String routerModel;

  const UpnpAuditReport({
    required this.gatewayIp,
    required this.isUpnpEnabled,
    this.externalWanIp,
    this.isDoubleNat = false,
    this.isCgnat = false,
    this.portMappings = const [],
    this.highRiskCount = 0,
    this.routerModel = 'Standard Gateway',
  });
}

/**
 * Router UPnP IGD & Security Auditor.
 * 
 * Conducts on-device WAN IP discovery and enumerates exposed port mappings
 * without relying on external cloud telemetry.
 */
class UpnpAuditor {
  static const List<int> upnpPorts = [1900, 5000, 49152, 5555, 80];

  /**
   * Conducts complete UPnP IGD audit on the specified gateway IP.
   */
  static Future<UpnpAuditReport> auditGateway(String gatewayIp) async {
    // 1. Probe candidate UPnP ports on gateway
    int? activePort;
    for (final port in upnpPorts) {
      if (await _isPortOpen(gatewayIp, port)) {
        activePort = port;
        break;
      }
    }

    if (activePort == null) {
      return UpnpAuditReport(
        gatewayIp: gatewayIp,
        isUpnpEnabled: false,
        routerModel: 'Secure / UPnP Disabled Gateway',
      );
    }

    // 2. Discover WAN IP via UPnP SOAP GetExternalIPAddress
    final wanIp = await _queryWanIp(gatewayIp, activePort);
    final isDoubleNat = wanIp != null && SubnetCalculator.isPrivateIp(wanIp);
    final isCgnat = wanIp != null && SubnetCalculator.isCgnatIp(wanIp);

    // 3. Enumerate port mappings
    final mappings = await _queryPortMappings(gatewayIp, activePort);
    final highRisks = mappings.where((m) => m.isHighRisk).length;

    return UpnpAuditReport(
      gatewayIp: gatewayIp,
      isUpnpEnabled: true,
      externalWanIp: wanIp,
      isDoubleNat: isDoubleNat,
      isCgnat: isCgnat,
      portMappings: mappings,
      highRiskCount: highRisks,
      routerModel: 'UPnP IGD Active Gateway',
    );
  }

  static Future<bool> _isPortOpen(String host, int port) async {
    try {
      final s = await Socket.connect(host, port, timeout: const Duration(milliseconds: 250));
      s.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> _queryWanIp(String host, int port) async {
    try {
      final client = HttpClient()..connectionTimeout = const Duration(milliseconds: 600);
      final request = await client.post(host, port, '/ipc/control/wanipconnection');
      request.headers.set('SOAPAction', '"urn:schemas-upnp-org:service:WANIPConnection:1#GetExternalIPAddress"');
      request.headers.set('Content-Type', 'text/xml; charset="utf-8"');

      final soap = '''<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <s:Body>
    <u:GetExternalIPAddress xmlns:u="urn:schemas-upnp-org:service:WANIPConnection:1"/>
  </s:Body>
</s:Envelope>''';

      request.write(soap);
      final response = await request.close().timeout(const Duration(milliseconds: 800));
      final body = await response.transform(utf8.decoder).join();
      client.close();

      final match = RegExp(r'<NewExternalIPAddress>(.*?)</NewExternalIPAddress>').firstMatch(body);
      if (match != null && match.group(1) != null) {
        final ip = match.group(1)!.trim();
        if (ip.isNotEmpty && ip != '0.0.0.0') return ip;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<List<UpnpPortMapping>> _queryPortMappings(String host, int port) async {
    final List<UpnpPortMapping> list = [];
    // Enumerate first 5 entries
    for (int index = 0; index < 5; index++) {
      try {
        final client = HttpClient()..connectionTimeout = const Duration(milliseconds: 400);
        final request = await client.post(host, port, '/ipc/control/wanipconnection');
        request.headers.set('SOAPAction', '"urn:schemas-upnp-org:service:WANIPConnection:1#GetGenericPortMappingEntry"');
        request.headers.set('Content-Type', 'text/xml; charset="utf-8"');

        final soap = '''<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <s:Body>
    <u:GetGenericPortMappingEntry xmlns:u="urn:schemas-upnp-org:service:WANIPConnection:1">
      <NewPortMappingIndex>$index</NewPortMappingIndex>
    </u:GetGenericPortMappingEntry>
  </s:Body>
</s:Envelope>''';

        request.write(soap);
        final response = await request.close().timeout(const Duration(milliseconds: 500));
        final body = await response.transform(utf8.decoder).join();
        client.close();

        if (response.statusCode != 200 || !body.contains('NewExternalPort')) {
          break; // No more entries
        }

        final extPort = int.tryParse(RegExp(r'<NewExternalPort>(.*?)</NewExternalPort>').firstMatch(body)?.group(1) ?? '') ?? 0;
        final intPort = int.tryParse(RegExp(r'<NewInternalPort>(.*?)</NewInternalPort>').firstMatch(body)?.group(1) ?? '') ?? 0;
        final clientIp = RegExp(r'<NewInternalClient>(.*?)</NewInternalClient>').firstMatch(body)?.group(1) ?? '';
        final proto = RegExp(r'<NewProtocol>(.*?)</NewProtocol>').firstMatch(body)?.group(1) ?? 'TCP';
        final desc = RegExp(r'<NewPortMappingDescription>(.*?)</NewPortMappingDescription>').firstMatch(body)?.group(1) ?? 'Mapping';

        if (extPort > 0) {
          list.add(UpnpPortMapping(
            externalPort: extPort,
            internalPort: intPort,
            internalClient: clientIp,
            protocol: proto,
            description: desc,
          ));
        }
      } catch (_) {
        break;
      }
    }
    return list;
  }
}
