import 'dart:async';
import 'dart:io';
import '../models/lan_device.dart';
import './subnet_calculator.dart';
import './device_fingerprinter.dart';
import './oui_database.dart';
import './camera_sentry_engine.dart';

/**
 * High-Speed Multi-Tier Subnet Discovery Engine.
 * 
 * Conducts bounded asynchronous socket sweeps across IPv4 subnets,
 * detecting active hosts via both TCP Established handshakes and TCP RST replies.
 */
class SubnetDiscoveryEngine {
  static const List<int> fastProbePorts = [80, 443, 445, 139, 22, 8080, 554, 62078];
  static const int socketTimeoutMs = 120;
  static const int maxConcurrentSockets = 128;

  bool _isCancelled = false;

  void cancel() {
    _isCancelled = true;
  }

  /**
   * Sweeps the subnet specified by [localIp] and [netmask], streaming discovered devices.
   */
  Stream<LanDevice> sweepSubnet({
    required String localIp,
    String netmask = '255.255.255.0',
    String gatewayIp = '192.168.1.1',
    void Function(double progress)? onProgress,
  }) async* {
    _isCancelled = false;
    final calc = SubnetCalculator.calculate(localIp: localIp, netmask: netmask);
    final targetIps = calc.targetIps;
    final total = targetIps.length;

    int scannedCount = 0;
    final batchSize = maxConcurrentSockets;

    for (int i = 0; i < targetIps.length; i += batchSize) {
      if (_isCancelled) break;

      final chunk = targetIps.sublist(
        i,
        (i + batchSize > targetIps.length) ? targetIps.length : i + batchSize,
      );

      final futures = chunk.map((ip) => _probeHost(
        ip: ip,
        isGateway: ip == gatewayIp,
        isLocal: ip == localIp,
      ));

      final results = await Future.wait(futures);

      for (final device in results) {
        if (device != null) {
          yield device;
        }
      }

      scannedCount += chunk.length;
      if (onProgress != null && total > 0) {
        onProgress((scannedCount / total).clamp(0.0, 1.0));
      }
    }
  }

  /**
   * Probes an individual IP address across key ports.
   * Recognizes TCP RST (Connection Refused) as proof of host presence.
   */
  Future<LanDevice?> _probeHost({
    required String ip,
    required bool isGateway,
    required bool isLocal,
  }) async {
    final sw = Stopwatch()..start();
    bool isAlive = isLocal;
    final List<int> openPorts = [];
    double latency = 0.0;

    for (final port in fastProbePorts) {
      if (_isCancelled) return null;
      try {
        final socket = await Socket.connect(
          ip,
          port,
          timeout: const Duration(milliseconds: socketTimeoutMs),
        );
        isAlive = true;
        openPorts.add(port);
        if (latency == 0.0) latency = sw.elapsedMicroseconds / 1000.0;
        socket.destroy();
      } on SocketException catch (e) {
        // Conclusive: If Connection Refused (TCP RST received), the IP host is definitely ALIVE!
        final msg = e.message.toLowerCase();
        final osMsg = e.osError?.message.toLowerCase() ?? '';
        if (msg.contains('connection refused') || osMsg.contains('connection refused')) {
          isAlive = true;
          if (latency == 0.0) latency = sw.elapsedMicroseconds / 1000.0;
        }
      } catch (_) {
        // Timeout or unroutable
      }

      if (isAlive && openPorts.isNotEmpty) {
        break; // Fast bail once host presence and at least one port confirmed
      }
    }

    if (!isAlive) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final isCamera = openPorts.contains(554);

    final category = DeviceFingerprinter.classify(
      ip: ip,
      openPorts: openPorts,
      isGateway: isGateway,
    );

    return LanDevice(
      ip: ip,
      openPorts: openPorts,
      pingLatencyMs: double.parse((latency > 0 ? latency : 1.2).toStringAsFixed(1)),
      category: category,
      firstSeenMs: now,
      lastSeenMs: now,
      isGateway: isGateway,
      isLocalDevice: isLocal,
      isCamera: isCamera,
      vendor: isGateway ? 'Gateway Router' : (isLocal ? 'This Device' : 'Local Device'),
    );
  }

  /**
   * Conducts targeted multi-port sweep on a single host across top 20 ports.
   */
  static Future<List<int>> scanTargetedPorts(String ip) async {
    final targetPorts = [
      21, 22, 23, 25, 53, 80, 110, 139, 143, 443, 445,
      554, 631, 993, 995, 1900, 3389, 5000, 8000, 8080, 8443, 9100,
    ];

    final List<int> detected = [];
    for (final port in targetPorts) {
      try {
        final s = await Socket.connect(ip, port, timeout: const Duration(milliseconds: 150));
        detected.add(port);
        s.destroy();
      } catch (_) {}
    }
    return detected;
  }
}
