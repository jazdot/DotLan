import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/lan_device.dart';
import '../../../core/theme/obsidian_theme.dart';
import '../../../core/widgets/device_detail_sheet.dart';
import '../../lan_cubit/lan_cubit.dart';
import '../../lan_cubit/lan_state.dart';

/**
 * Tab 2: Categorized Host Inventory & Port Inspection.
 */
class InventoryTab extends StatelessWidget {
  const InventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanCubit, LanState>(
      builder: (context, state) {
        final list = state.filteredDevices;

        return Column(
          children: [
            // Filter Chips Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: ObsidianTheme.spaceLg,
                vertical: ObsidianTheme.spaceSm,
              ),
              child: Row(
                children: [
                  _buildFilterChip(context, label: 'ALL (${state.devices.length})', category: null, active: state.filterCategory == null),
                  _buildFilterChip(context, label: 'CAMERAS', category: DeviceCategory.camera, active: state.filterCategory == DeviceCategory.camera),
                  _buildFilterChip(context, label: 'GATEWAY', category: DeviceCategory.gateway, active: state.filterCategory == DeviceCategory.gateway),
                  _buildFilterChip(context, label: 'COMPUTE', category: DeviceCategory.workstation, active: state.filterCategory == DeviceCategory.workstation),
                  _buildFilterChip(context, label: 'MOBILE', category: DeviceCategory.mobile, active: state.filterCategory == DeviceCategory.mobile),
                  _buildFilterChip(context, label: 'SMART IOT', category: DeviceCategory.iot, active: state.filterCategory == DeviceCategory.iot),
                  _buildFilterChip(context, label: 'PRINTERS', category: DeviceCategory.printer, active: state.filterCategory == DeviceCategory.printer),
                  _buildFilterChip(context, label: 'MEDIA', category: DeviceCategory.entertainment, active: state.filterCategory == DeviceCategory.entertainment),
                ],
              ),
            ),

            // Device List View
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.devices_other, size: 40, color: ObsidianTheme.textTertiary),
                          const SizedBox(height: 8),
                          Text(
                            state.isScanning ? 'Sweeping subnet for endpoints...' : 'No devices found in this filter.',
                            style: TextStyle(color: ObsidianTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ObsidianTheme.spaceLg,
                        vertical: ObsidianTheme.spaceSm,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final dev = list[index];
                        return _buildDeviceCard(context, dev);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required DeviceCategory? category,
    required bool active,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: active ? const Color(0xFF05070B) : ObsidianTheme.textSecondary,
          ),
        ),
        selected: active,
        selectedColor: ObsidianTheme.accentGold,
        backgroundColor: ObsidianTheme.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
          side: BorderSide(color: active ? ObsidianTheme.accentGold : ObsidianTheme.borderSubtle),
        ),
        onSelected: (_) {
          context.read<LanCubit>().setCategoryFilter(category);
        },
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, LanDevice dev) {
    Color badgeColor;
    if (dev.isConfirmedCamera) {
      badgeColor = const Color(0xFFEF4444);
    } else if (dev.isCamera) {
      badgeColor = const Color(0xFFF59E0B);
    } else if (dev.isGateway) {
      badgeColor = const Color(0xFFFBBF24);
    } else {
      badgeColor = const Color(0xFF10B981);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: ObsidianTheme.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ObsidianTheme.radiusMd),
        side: BorderSide(color: dev.isConfirmedCamera ? const Color(0x66EF4444) : ObsidianTheme.borderSubtle),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(ObsidianTheme.radiusMd),
        onTap: () {
          context.read<LanCubit>().selectDevice(dev);
          DeviceDetailSheet.show(context, dev);
        },
        child: Padding(
          padding: const EdgeInsets.all(ObsidianTheme.spaceMd),
          child: Row(
            children: [
              // Icon Badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
                  border: Border.all(color: badgeColor.withOpacity(0.4)),
                ),
                child: Icon(_getCategoryIcon(dev), size: 18, color: badgeColor),
              ),
              const SizedBox(width: ObsidianTheme.spaceMd),

              // Device Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          dev.ip,
                          style: ObsidianTheme.tabularNumberStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (dev.isLocalDevice)
                          _buildMiniTag('YOU', const Color(0xFF3B82F6))
                        else if (dev.isGateway)
                          _buildMiniTag('GATEWAY', ObsidianTheme.accentGold)
                        else if (dev.isConfirmedCamera)
                          _buildMiniTag('CONFIRMED CAM', const Color(0xFFEF4444)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${dev.displayName}  •  ${dev.resolvedVendor}',
                      style: TextStyle(fontSize: 11, color: ObsidianTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Ping Latency
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${dev.pingLatencyMs}ms',
                    style: ObsidianTheme.tabularNumberStyle(fontSize: 11, color: const Color(0xFF10B981)),
                  ),
                  Text(
                    dev.openPorts.isEmpty ? 'ports: -' : 'ports: ${dev.openPorts.length}',
                    style: TextStyle(fontSize: 9, color: ObsidianTheme.textTertiary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  IconData _getCategoryIcon(LanDevice dev) {
    switch (dev.category) {
      case DeviceCategory.gateway:
        return Icons.router;
      case DeviceCategory.camera:
        return Icons.videocam;
      case DeviceCategory.workstation:
        return Icons.computer;
      case DeviceCategory.mobile:
        return Icons.smartphone;
      case DeviceCategory.iot:
        return Icons.lightbulb_outline;
      case DeviceCategory.printer:
        return Icons.print;
      case DeviceCategory.entertainment:
        return Icons.tv;
      case DeviceCategory.unknown:
        return Icons.device_hub;
    }
  }
}
