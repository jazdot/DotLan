import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/lan_device.dart';
import '../../core/theme/obsidian_theme.dart';
import '../../core/export/ocsf_exporter.dart';
import '../../features/lan_cubit/lan_cubit.dart';
import '../../features/lan_cubit/lan_state.dart';

/**
 * Bottom inspection sheet for deep analysis of a selected network endpoint.
 */
class DeviceDetailSheet extends StatelessWidget {
  final LanDevice device;

  const DeviceDetailSheet({super.key, required this.device});

  static void show(BuildContext context, LanDevice device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeviceDetailSheet(device: device),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanCubit, LanState>(
      builder: (context, state) {
        final currentDev = state.devices.firstWhere(
          (d) => d.ip == device.ip,
          orElse: () => device,
        );

        return Container(
          padding: const EdgeInsets.all(ObsidianTheme.spaceLg),
          decoration: BoxDecoration(
            color: ObsidianTheme.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(ObsidianTheme.radiusXl)),
            border: Border.all(color: ObsidianTheme.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ObsidianTheme.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: ObsidianTheme.spaceMd),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentDev.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ObsidianTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'IP: ${currentDev.ip}  •  ${currentDev.resolvedVendor}',
                        style: TextStyle(
                          fontSize: 12,
                          color: ObsidianTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: currentDev.isConfirmedCamera
                          ? const Color(0x33EF4444)
                          : const Color(0x2210B981),
                      borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
                      border: Border.all(
                        color: currentDev.isConfirmedCamera
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                      ),
                    ),
                    child: Text(
                      currentDev.isConfirmedCamera
                          ? 'CONFIRMED CAMERA'
                          : currentDev.category.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: currentDev.isConfirmedCamera
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ObsidianTheme.spaceMd),

              // Telemetry Grid
              Container(
                padding: const EdgeInsets.all(ObsidianTheme.spaceMd),
                decoration: ObsidianTheme.cardDecoration(),
                child: Column(
                  children: [
                    _buildRow('MAC Address', currentDev.mac ?? 'Hidden by OS (OUI Resolved)'),
                    _buildRow('Ping Latency', '${currentDev.pingLatencyMs} ms'),
                    _buildRow('Open Ports', currentDev.openPorts.isEmpty ? 'None probed' : currentDev.openPorts.join(', ')),
                    if (currentDev.cameraProtocol != null)
                      _buildRow('Stream Protocol', currentDev.cameraProtocol!),
                  ],
                ),
              ),
              const SizedBox(height: ObsidianTheme.spaceMd),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ObsidianTheme.borderActive),
                        foregroundColor: ObsidianTheme.textPrimary,
                      ),
                      onPressed: state.isTargetedScanning
                          ? null
                          : () {
                              context.read<LanCubit>().scanPortsForSelectedDevice();
                            },
                      child: Text(
                        state.isTargetedScanning ? 'Scanning...' : 'Inspect 20 Ports',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: ObsidianTheme.spaceSm),
                  if (currentDev.isCamera || currentDev.openPorts.contains(554) || currentDev.openPorts.contains(8000))
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          context.read<LanCubit>().verifyCameraHost(currentDev.ip);
                        },
                        child: const Text(
                          'Verify RTSP/ONVIF',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: ObsidianTheme.spaceSm),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: ObsidianTheme.textTertiary)),
          Text(value, style: ObsidianTheme.tabularNumberStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
