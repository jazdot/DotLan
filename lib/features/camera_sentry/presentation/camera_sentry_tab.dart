import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/obsidian_theme.dart';
import '../../../core/export/pdf_audit_report_generator.dart';
import '../../lan_cubit/lan_cubit.dart';
import '../../lan_cubit/lan_state.dart';

/**
 * Tab 3: Traveler Hidden Camera & Surveillance Stream Sentry.
 */
class CameraSentryTab extends StatelessWidget {
  const CameraSentryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanCubit, LanState>(
      builder: (context, state) {
        final cameras = state.devices.where((d) => d.isCamera || d.isConfirmedCamera).toList();
        final score = state.safetyScore;
        final isClean = score == 100;

        return ListView(
          padding: const EdgeInsets.all(ObsidianTheme.spaceLg),
          children: [
            // 1. Traveler Safety Clearance Banner
            Container(
              padding: const EdgeInsets.all(ObsidianTheme.spaceLg),
              decoration: BoxDecoration(
                color: isClean ? const Color(0x1A10B981) : const Color(0x26EF4444),
                borderRadius: BorderRadius.circular(ObsidianTheme.radiusLg),
                border: Border.all(
                  color: isClean ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isClean ? Icons.verified_user : Icons.warning_amber_rounded,
                    size: 44,
                    color: isClean ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                  const SizedBox(height: ObsidianTheme.spaceSm),
                  Text(
                    'ROOM SAFETY SCORE: $score%',
                    style: ObsidianTheme.tabularNumberStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isClean ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isClean
                        ? 'Zero covert video feeds detected on this Wi-Fi network.'
                        : '${cameras.length} active video streaming listener(s) discovered!',
                    style: TextStyle(
                      fontSize: 12,
                      color: ObsidianTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: ObsidianTheme.spaceLg),

            // 2. Protocols Checked Explanation
            Container(
              padding: const EdgeInsets.all(ObsidianTheme.spaceMd),
              decoration: ObsidianTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SURVEILLANCE RADAR TARGETS',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: ObsidianTheme.textTertiary),
                  ),
                  const SizedBox(height: 8),
                  _buildProtocolRow('RTSP (Port 554)', 'Real-Time Streaming Protocol (H.264 / H.265 feeds)'),
                  _buildProtocolRow('ONVIF (Port 8000/8899)', 'Open Network Video Interface Forum discovery'),
                  _buildProtocolRow('MJPEG HTTP (Port 8080)', 'Motion JPEG raw browser surveillance streams'),
                ],
              ),
            ),
            const SizedBox(height: ObsidianTheme.spaceLg),

            // 3. Detected Camera Feeds
            Text(
              'DETECTED VIDEO STREAMING ENDPOINTS (${cameras.length})',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: ObsidianTheme.textTertiary),
            ),
            const SizedBox(height: ObsidianTheme.spaceSm),

            if (cameras.isEmpty)
              Container(
                padding: const EdgeInsets.all(ObsidianTheme.spaceLg),
                decoration: ObsidianTheme.cardDecoration(),
                child: Center(
                  child: Text(
                    'Subnet is clear. No camera streams found.',
                    style: TextStyle(color: ObsidianTheme.textTertiary, fontSize: 12),
                  ),
                ),
              )
            else
              ...cameras.map((cam) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: ObsidianTheme.bgSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ObsidianTheme.radiusMd),
                      side: BorderSide(
                        color: cam.isConfirmedCamera ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(ObsidianTheme.spaceMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                cam.ip,
                                style: ObsidianTheme.tabularNumberStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cam.isConfirmedCamera ? const Color(0x33EF4444) : const Color(0x33F59E0B),
                                  borderRadius: BorderRadius.circular(ObsidianTheme.radiusSm),
                                ),
                                child: Text(
                                  cam.isConfirmedCamera ? 'CONFIRMED RTSP' : 'SUSPECTED',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: cam.isConfirmedCamera ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${cam.resolvedVendor} • Protocol: ${cam.cameraProtocol ?? "RTSP / Port 554"}',
                            style: TextStyle(fontSize: 11, color: ObsidianTheme.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: ObsidianTheme.borderActive),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              onPressed: () {
                                context.read<LanCubit>().verifyCameraHost(cam.ip);
                              },
                              child: const Text(
                                'Run Deep RTSP Handshake',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),

            const SizedBox(height: ObsidianTheme.spaceLg),

            // 4. Export Safety Audit Certificate
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: ObsidianTheme.accentGold,
                foregroundColor: const Color(0xFF05070B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ObsidianTheme.radiusMd),
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text(
                'EXPORT VERIFIED SAFETY CERTIFICATE',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8),
              ),
              onPressed: () {
                final markdown = PdfAuditReportGenerator.generateExecutiveAuditReportMarkdown(
                  devices: state.devices,
                  rfContext: state.rfContext,
                  upnpMappings: state.upnpReport?.portMappings ?? [],
                  safetyScore: score,
                );

                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: ObsidianTheme.bgElevated,
                    title: Text(
                      'Jazdot Verified Audit Certificate',
                      style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 14),
                    ),
                    content: SingleChildScrollView(
                      child: Text(
                        markdown,
                        style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: ObsidianTheme.textSecondary),
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
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProtocolRow(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF10B981)),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 11, color: ObsidianTheme.textSecondary),
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
