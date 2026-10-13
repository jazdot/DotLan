import 'package:flutter/material.dart';
import '../../core/theme/obsidian_theme.dart';
import 'dot_lan_animated_logo.dart';

/**
 * Jazdot Suite Navigation Drawer.
 * 
 * Provides cross-navigation between DotSignal (Cellular 5G), DotBand (Wi-Fi 6E/7 Spectrum),
 * and DotLan (Subnet Radar), with bridges to enterprise dotedge platforms.
 */
class JazdotSuiteDrawer extends StatelessWidget {
  const JazdotSuiteDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ObsidianTheme.bgBase,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(ObsidianTheme.spaceLg),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: ObsidianTheme.borderSubtle)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DotLanAnimatedLogo(size: 40, showWordmark: true),
                  const SizedBox(height: ObsidianTheme.spaceSm),
                  Text(
                    'JAZDOT ENTERPRISES MOBILE NETWORK SUITE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: ObsidianTheme.accentGold,
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: ObsidianTheme.spaceSm),
                children: [
                  _buildNavItem(
                    context,
                    title: 'DotLan',
                    subtitle: 'Local Subnet Discovery & Camera Radar',
                    icon: Icons.radar,
                    isActive: true,
                    tag: 'ACTIVE APP',
                  ),
                  _buildNavItem(
                    context,
                    title: 'DotSignal',
                    subtitle: 'Cellular & 5G Baseband Telemetry Engine',
                    icon: Icons.cell_tower,
                    isActive: false,
                    tag: '3GPP NR',
                  ),
                  _buildNavItem(
                    context,
                    title: 'DotBand',
                    subtitle: 'Wi-Fi 6E / 7 Spectrum & Channel Analyzer',
                    icon: Icons.wifi_find,
                    isActive: false,
                    tag: '802.11be',
                  ),

                  const Divider(height: 32, indent: 16, endIndent: 16),

                  // Enterprise Bridge Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ObsidianTheme.spaceLg),
                    child: Container(
                      padding: const EdgeInsets.all(ObsidianTheme.spaceMd),
                      decoration: ObsidianTheme.cardDecoration(hasGoldBorder: true),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.shield_outlined, size: 16, color: ObsidianTheme.accentGold),
                              const SizedBox(width: 6),
                              Text(
                                'JAZDOT DOTEDGE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: ObsidianTheme.accentGold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Isolate commercial IoT devices with on-premises K3s micro-orchestration & zero-trust UPF.',
                            style: TextStyle(fontSize: 10, color: ObsidianTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Theme Toggle & Footer
            Container(
              padding: const EdgeInsets.all(ObsidianTheme.spaceLg),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: ObsidianTheme.borderSubtle)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Theme Mode',
                    style: TextStyle(fontSize: 12, color: ObsidianTheme.textSecondary),
                  ),
                  IconButton(
                    icon: Icon(
                      ObsidianTheme.isLight ? Icons.dark_mode : Icons.light_mode,
                      color: ObsidianTheme.accentGold,
                    ),
                    onPressed: () {
                      final current = ObsidianTheme.themeModeNotifier.value;
                      ObsidianTheme.themeModeNotifier.value =
                          current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required String tag,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? ObsidianTheme.accentGold : ObsidianTheme.textTertiary,
      ),
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isActive ? ObsidianTheme.textPrimary : ObsidianTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isActive ? const Color(0x33D97706) : ObsidianTheme.bgSubtle,
              borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: isActive ? ObsidianTheme.accentGold : ObsidianTheme.textTertiary,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 10, color: ObsidianTheme.textTertiary),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
