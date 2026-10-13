import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/obsidian_theme.dart';
import '../../../core/widgets/device_detail_sheet.dart';
import '../../lan_cubit/lan_cubit.dart';
import '../../lan_cubit/lan_state.dart';
import 'topology_radar_canvas.dart';

/**
 * Tab 1: 360-Degree Subnet Radar & Physical RF HUD.
 */
class RadarTab extends StatelessWidget {
  const RadarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanCubit, LanState>(
      builder: (context, state) {
        final rf = state.rfContext;

        return Column(
          children: [
            // 1. Wi-Fi Physical Layer RF HUD Banner
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ObsidianTheme.spaceLg,
                vertical: ObsidianTheme.spaceSm,
              ),
              color: ObsidianTheme.bgSurface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wifi, size: 16, color: ObsidianTheme.accentGold),
                      const SizedBox(width: 6),
                      Text(
                        '${rf.ssid} (${rf.wifiStandard})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ObsidianTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${rf.frequencyBandDescription} • ${rf.channelWidthMhz}MHz',
                        style: ObsidianTheme.tabularNumberStyle(fontSize: 10, color: ObsidianTheme.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0x2210B981),
                          borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
                        ),
                        child: Text(
                          '${rf.rssiDbm} dBm',
                          style: ObsidianTheme.tabularNumberStyle(
                            fontSize: 10,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scan Progress Indicator
            if (state.isScanning)
              LinearProgressIndicator(
                value: state.scanProgress > 0 ? state.scanProgress : null,
                backgroundColor: ObsidianTheme.bgSubtle,
                valueColor: AlwaysStoppedAnimation<Color>(ObsidianTheme.accentGold),
                minHeight: 2.0,
              ),

            // 2. Interactive 360-Degree Radar Topology Canvas
            Expanded(
              child: Stack(
                children: [
                  TopologyRadarCanvas(
                    devices: state.devices,
                    isScanning: state.isScanning,
                    selectedDevice: state.selectedDevice,
                    onDeviceSelected: (device) {
                      context.read<LanCubit>().selectDevice(device);
                      DeviceDetailSheet.show(context, device);
                    },
                  ),

                  // Radar HUD Watermark
                  Positioned(
                    top: 12,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SUBNET RADAR',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: ObsidianTheme.textTertiary,
                          ),
                        ),
                        Text(
                          'ACTIVE HOSTS: ${state.devices.length}',
                          style: ObsidianTheme.tabularNumberStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Safety Clearance Badge
                  Positioned(
                    top: 12,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: state.confirmedCameraCount > 0
                            ? const Color(0x33EF4444)
                            : const Color(0x2210B981),
                        borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
                        border: Border.all(
                          color: state.confirmedCameraCount > 0
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            state.confirmedCameraCount > 0
                                ? Icons.videocam
                                : Icons.security,
                            size: 12,
                            color: state.confirmedCameraCount > 0
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'SAFETY: ${state.safetyScore}%',
                            style: ObsidianTheme.tabularNumberStyle(
                              fontSize: 10,
                              color: state.confirmedCameraCount > 0
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Bottom HUD Metrics & Scan Trigger CTA
            Container(
              padding: const EdgeInsets.all(ObsidianTheme.spaceMd),
              decoration: BoxDecoration(
                color: ObsidianTheme.bgSurface,
                border: Border(top: BorderSide(color: ObsidianTheme.borderSubtle)),
              ),
              child: Row(
                children: [
                  _buildMetric('GATEWAY', rf.gatewayIp),
                  const SizedBox(width: ObsidianTheme.spaceMd),
                  _buildMetric('CAMERAS', '${state.confirmedCameraCount} Detected'),
                  const SizedBox(width: ObsidianTheme.spaceMd),
                  _buildMetric('LATENCY', state.devices.isEmpty ? '0 ms' : '${state.devices.first.pingLatencyMs} ms'),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ObsidianTheme.accentGold,
                      foregroundColor: const Color(0xFF05070B),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ObsidianTheme.radiusMd),
                      ),
                    ),
                    icon: state.isScanning
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF05070B)),
                          )
                        : const Icon(Icons.radar, size: 16),
                    label: Text(
                      state.isScanning ? 'SWEEPING' : 'SWEEP SUBNET',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                    ),
                    onPressed: state.isScanning
                        ? null
                        : () => context.read<LanCubit>().startScan(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: ObsidianTheme.textTertiary),
        ),
        Text(
          value,
          style: ObsidianTheme.tabularNumberStyle(fontSize: 12, color: ObsidianTheme.textPrimary),
        ),
      ],
    );
  }
}
