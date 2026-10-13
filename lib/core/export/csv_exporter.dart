import '../models/lan_device.dart';

/**
 * CSV Subnet Inventory Exporter.
 */
class CsvExporter {
  static String exportCsv(List<LanDevice> devices) {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln('IP_Address,MAC_Address,Hostname,Vendor,Category,Latency_ms,Open_Ports,Camera_Detected,Confirmed_Feed');

    for (final d in devices) {
      final ip = d.ip;
      final mac = d.mac ?? 'N/A';
      final host = (d.hostname ?? d.displayName).replaceAll(',', ';');
      final vendor = d.resolvedVendor.replaceAll(',', ';');
      final cat = d.category.name;
      final lat = d.pingLatencyMs;
      final ports = '"${d.openPorts.join(',')}"';
      final isCam = d.isCamera ? 'YES' : 'NO';
      final isConf = d.isConfirmedCamera ? 'YES' : 'NO';

      buffer.writeln('$ip,$mac,$host,$vendor,$cat,$lat,$ports,$isCam,$isConf');
    }

    return buffer.toString();
  }
}
