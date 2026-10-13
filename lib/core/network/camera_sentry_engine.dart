import 'dart:async';
import 'dart:convert';
import 'dart:io';

/**
 * Result of a deep camera verification handshake.
 */
class CameraVerificationResult {
  final String ip;
  final bool isConfirmedCamera;
  final bool isSuspectedStream;
  final String protocol;
  final String serverBanner;
  final double confidenceScore; // 0.0 to 1.0
  final String details;

  const CameraVerificationResult({
    required this.ip,
    required this.isConfirmedCamera,
    required this.isSuspectedStream,
    required this.protocol,
    required this.serverBanner,
    required this.confidenceScore,
    required this.details,
  });

  factory CameraVerificationResult.clean(String ip) {
    return CameraVerificationResult(
      ip: ip,
      isConfirmedCamera: false,
      isSuspectedStream: false,
      protocol: 'None',
      serverBanner: 'Clean',
      confidenceScore: 0.0,
      details: 'No video streaming listeners detected.',
    );
  }
}

/**
 * Hidden Camera & RTSP / ONVIF Sentry Engine.
 * 
 * Conducts multi-stage protocol handshakes to confirm genuine video feeds
 * and eliminate false positives on generic development or web servers.
 */
class CameraSentryEngine {
  static const int rtspPort = 554;
  static const List<int> onvifCandidatePorts = [8000, 8899, 5000];
  static const int defaultTimeoutMs = 350;

  /**
   * Evaluates if a given host is hosting an active surveillance feed.
   */
  static Future<CameraVerificationResult> inspectHost(String ip) async {
    // Stage 1: RTSP (RFC 2326) Probe
    final rtspResult = await probeRtsp(ip);
    if (rtspResult.isConfirmedCamera) {
      return rtspResult;
    }

    // Stage 2: ONVIF / Web Camera Probe
    for (final port in onvifCandidatePorts) {
      final onvifResult = await probeOnvifHttp(ip, port);
      if (onvifResult.isConfirmedCamera || onvifResult.isSuspectedStream) {
        return onvifResult;
      }
    }

    return CameraVerificationResult.clean(ip);
  }

  /**
   * Transmits RTSP OPTIONS packet to verify RFC 2326 streaming server.
   */
  static Future<CameraVerificationResult> probeRtsp(String ip) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        ip,
        rtspPort,
        timeout: const Duration(milliseconds: defaultTimeoutMs),
      );

      final request = 'OPTIONS * RTSP/1.0\r\nCSeq: 1\r\nUser-Agent: DotLan-CameraSentry/2.1\r\n\r\n';
      socket.add(utf8.encode(request));
      await socket.flush();

      final completer = Completer<String>();
      final subscription = socket.listen(
        (data) {
          if (!completer.isCompleted) {
            completer.complete(utf8.decode(data, allowMalformed: true));
          }
        },
        onError: (_) {
          if (!completer.isCompleted) completer.complete('');
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete('');
        },
      );

      final response = await completer.future.timeout(
        const Duration(milliseconds: 400),
        onTimeout: () => '',
      );

      await subscription.cancel();
      socket.destroy();

      if (response.contains('RTSP/1.0 200 OK') ||
          response.contains('RTSP/2.0 200 OK') ||
          (response.contains('RTSP/') && response.contains('Public:'))) {
        String banner = 'Generic RTSP Server';
        final lines = response.split('\r\n');
        for (final line in lines) {
          if (line.toLowerCase().startsWith('server:')) {
            banner = line.substring(7).trim();
            break;
          }
        }
        return CameraVerificationResult(
          ip: ip,
          isConfirmedCamera: true,
          isSuspectedStream: false,
          protocol: 'RTSP (RFC 2326)',
          serverBanner: banner,
          confidenceScore: 0.98,
          details: 'Active RTSP video streaming feed confirmed.',
        );
      }

      // Port 554 was open, but returned non-standard response
      return CameraVerificationResult(
        ip: ip,
        isConfirmedCamera: false,
        isSuspectedStream: true,
        protocol: 'RTSP (Port 554)',
        serverBanner: 'Unresponsive Banner',
        confidenceScore: 0.70,
        details: 'RTSP port 554 is open. Streaming capability suspected.',
      );
    } catch (_) {
      socket?.destroy();
      return CameraVerificationResult.clean(ip);
    }
  }

  /**
   * Probes candidate HTTP/ONVIF port with HTTP HEAD to inspect server banner.
   */
  static Future<CameraVerificationResult> probeOnvifHttp(String ip, int port) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(milliseconds: defaultTimeoutMs),
      );

      final request = 'HEAD / HTTP/1.1\r\nHost: $ip\r\nConnection: close\r\n\r\n';
      socket.add(utf8.encode(request));
      await socket.flush();

      final completer = Completer<String>();
      final sub = socket.listen(
        (data) {
          if (!completer.isCompleted) {
            completer.complete(utf8.decode(data, allowMalformed: true));
          }
        },
        onError: (_) {
          if (!completer.isCompleted) completer.complete('');
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete('');
        },
      );

      final response = await completer.future.timeout(
        const Duration(milliseconds: 400),
        onTimeout: () => '',
      );

      await sub.cancel();
      socket.destroy();

      final lower = response.toLowerCase();
      // True camera servers commonly identify as Boa, GoAhead, Hikvision, Dahua, IPCamera
      if (lower.contains('boa') ||
          lower.contains('goahead') ||
          lower.contains('hikvision') ||
          lower.contains('dahua') ||
          lower.contains('ipcamera') ||
          lower.contains('onvif') ||
          lower.contains('realm="ip camera"')) {
        return CameraVerificationResult(
          ip: ip,
          isConfirmedCamera: true,
          isSuspectedStream: false,
          protocol: 'ONVIF / IP Web Cam',
          serverBanner: 'Verified Camera Firmware',
          confidenceScore: 0.95,
          details: 'Camera administration & streaming interface identified on port $port.',
        );
      }

      // Generic web server like Python, Apache, Nginx, Node -> NOT a camera!
      return CameraVerificationResult.clean(ip);
    } catch (_) {
      socket?.destroy();
      return CameraVerificationResult.clean(ip);
    }
  }

  /**
   * Computes Traveler Room Safety Score (100% = No video cameras detected).
   */
  static int calculateSafetyScore({
    required int totalDevices,
    required int confirmedCameras,
    required int suspectedCameras,
  }) {
    if (confirmedCameras > 0) {
      return (30 - (confirmedCameras * 10)).clamp(0, 40);
    }
    if (suspectedCameras > 0) {
      return 65;
    }
    return 100;
  }
}
