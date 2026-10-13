import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/obsidian_theme.dart';
import '../../../core/export/ocsf_exporter.dart';
import '../../../core/export/csv_exporter.dart';
import '../../lan_cubit/lan_cubit.dart';
import '../../lan_cubit/lan_state.dart';

/**
 * Tab 4: Router UPnP IGD Security, Port Forwards, and Network Diagnostics.
 */
class DiagnosticsTab extends StatelessWidget {
  const DiagnosticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanCubit, LanState>(
      builder: (context, state) {
        final rf = state.rfContext;
        final upnp = state.upnpReport;
        final mappings = upnp?.portMappings ?? [];

        return ListView(
          padding: const EdgeInsets.all(ObsidianTheme.spaceLg),
          children: [
            // 1. Gateway & WAN IP Profile Card
            Container(
              padding: const EdgeInsets.all(ObsidianTheme.spaceMd),
              decoration: ObsidianTheme.cardDecoration(hasGoldBorder: true),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GATEWAY ROUTER & WAN TOPOLOGY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: ObsidianTheme.accentGold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: upnp?.isUpnpEnabled == true
                              ? const Color(0x33F59E0B)
                              : const Color(0x2210B981),
                          borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
                        ),
                        child: Text(
                          upnp?.isUpnpEnabled == true ? 'UPnP ACTIVE' : 'UPnP DISABLED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: upnp?.isUpnpEnabled == true
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildDiagRow('Gateway IP', rf.gatewayIp),
                  _buildDiagRow('Public WAN IP', rf.publicWanIp ?? 'Probing via IGD...'),
                  _buildDiagRow('Topology Mode', rf.isDoubleNat
                      ? 'DOUBLE-NAT (Behind Secondary Firewall)'
                      : (rf.isCgnat ? 'CARRIER-GRADE NAT (CGNAT RFC 6598)' : 'Standard Single NAT')),
                  _buildDiagRow('DNS Server', '${rf.dnsServer} (Canary Verified)'),
                ],
              ),
            ),
            const SizedBox(height: ObsidianTheme.spaceLg),

            // 2. UPnP Port Forwarding Table
            Text(
              'ROUTER UPNP PORT MAPPINGS EXPOSED TO WAN (${mappings.length})',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: ObsidianTheme.textTertiary),
            ),
            const SizedBox(height: ObsidianTheme.spaceSm),

            if (mappings.isEmpty)
              Container(
                padding: const EdgeInsets.all(ObsidianTheme.spaceLg),
                decoration: ObsidianTheme.cardDecoration(),
                child: Center(
                  child: Text(
                    upnp?.isUpnpEnabled == true
                        ? 'No active external port forwards configured.'
                        : 'UPnP is disabled or unexposed on router.',
                    style: TextStyle(color: ObsidianTheme.textTertiary, fontSize: 12),
                  ),
                ),
              )
            else
              ...mappings.map((m) => Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    color: ObsidianTheme.bgSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ObsidianTheme.radiusMd),
                      side: BorderSide(
                        color: m.isHighRisk ? const Color(0xFFEF4444) : ObsidianTheme.borderSubtle,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(ObsidianTheme.spaceMd),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'WAN Port ${m.externalPort}',
                                    style: ObsidianTheme.tabularNumberStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: m.isHighRisk ? const Color(0xFFEF4444) : ObsidianTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '➔ ${m.internalClient}:${m.internalPort} (${m.protocol})',
                                    style: TextStyle(fontSize: 11, color: ObsidianTheme.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                m.description,
                                style: TextStyle(fontSize: 10, color: ObsidianTheme.textTertiary),
                              ),
                            ],
                          ),
                          if (m.isHighRisk)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0x33EF4444),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'HIGH RISK',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFEF4444)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )),

            const SizedBox(height: ObsidianTheme.spaceLg),

            // 3. Telemetry Export Actions
            Text(
              'ENTERPRISE SIEM & TELEMETRY EXPORT',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: ObsidianTheme.textTertiary),
            ),
            const SizedBox(height: ObsidianTheme.spaceSm),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ObsidianTheme.borderActive),
                      foregroundColor: ObsidianTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.table_chart_outlined, size: 16),
                    label: const Text('Export CSV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    onPressed: () {
                      final csv = CsvExporter.exportCsv(state.devices);
                      _showExportDialog(context, 'Subnet Inventory CSV', csv);
                    },
                  ),
                ),
                const SizedBox(width: ObsidianTheme.spaceSm),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ObsidianTheme.borderActive),
                      foregroundColor: ObsidianTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.data_object, size: 16),
                    label: const Text('OCSF v1.3.0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    onPressed: () {
                      final jsonl = OcsfExporter.exportOcsfJsonl(
                        devices: state.devices,
                        rfContext: state.rfContext,
                      );
                      _showExportDialog(context, 'OCSF v1.3.0 (Class 4001) JSONL', jsonl);
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDiagRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: ObsidianTheme.textTertiary)),
          Text(value, style: ObsidianTheme.tabularNumberStyle(fontSize: 11)),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ObsidianTheme.bgElevated,
        title: Text(title, style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 13)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              content.isEmpty ? 'No devices available to export. Run a scan first.' : content,
              style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: ObsidianTheme.textSecondary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: TextStyle(color: ObsidianTheme.accentGold)),
          ),
        ],
      ),
    );
  }
}
