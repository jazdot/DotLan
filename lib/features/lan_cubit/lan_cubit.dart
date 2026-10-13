import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/lan_device.dart';
import '../../core/models/wifi_rf_context.dart';
import '../../core/network/subnet_discovery_engine.dart';
import '../../core/network/camera_sentry_engine.dart';
import '../../core/network/upnp_auditor.dart';
import '../../core/audio/field_feedback_engine.dart';
import './lan_state.dart';

/**
 * Reactive Business Logic Controller for DotLan Subnet Radar.
 */
class LanCubit extends Cubit<LanState> {
  final SubnetDiscoveryEngine _discoveryEngine = SubnetDiscoveryEngine();
  StreamSubscription<LanDevice>? _scanSubscription;

  LanCubit() : super(const LanState());

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    _discoveryEngine.cancel();
    return super.close();
  }

  void updateRfContext(WifiRfContext context) {
    emit(state.copyWith(rfContext: context));
  }

  void setCategoryFilter(DeviceCategory? category) {
    FieldFeedbackEngine.triggerSelectionClick();
    if (category == null) {
      emit(state.copyWith(clearFilter: true));
    } else {
      emit(state.copyWith(filterCategory: category));
    }
  }

  void selectDevice(LanDevice? device) {
    FieldFeedbackEngine.triggerSelectionClick();
    emit(state.copyWith(
      selectedDevice: device,
      targetedPorts: [],
      isTargetedScanning: false,
    ));
  }

  /**
   * Initiates asynchronous subnet sweep and router UPnP audit.
   */
  Future<void> startScan() async {
    if (state.isScanning) return;

    _scanSubscription?.cancel();
    _discoveryEngine.cancel();

    emit(state.copyWith(
      isScanning: true,
      scanProgress: 0.0,
      devices: [],
      statusMessage: 'Scanning local Wi-Fi subnet...',
      errorMessage: null,
    ));

    final Map<String, LanDevice> discoveredMap = {};

    // Audit gateway in parallel
    _auditGateway();

    try {
      final stream = _discoveryEngine.sweepSubnet(
        localIp: state.rfContext.localIp,
        netmask: state.rfContext.netmask,
        gatewayIp: state.rfContext.gatewayIp,
        onProgress: (p) {
          emit(state.copyWith(scanProgress: p));
        },
      );

      _scanSubscription = stream.listen(
        (device) {
          discoveredMap[device.ip] = device;
          FieldFeedbackEngine.triggerRadarTick();

          final updatedList = discoveredMap.values.toList()
            ..sort((a, b) => a.ip.compareTo(b.ip));

          final score = CameraSentryEngine.calculateSafetyScore(
            totalDevices: updatedList.length,
            confirmedCameras: updatedList.where((d) => d.isConfirmedCamera).length,
            suspectedCameras: updatedList.where((d) => d.isCamera).length,
          );

          emit(state.copyWith(
            devices: updatedList,
            safetyScore: score,
          ));
        },
        onError: (err) {
          emit(state.copyWith(
            isScanning: false,
            errorMessage: 'Scan error: $err',
          ));
        },
        onDone: () {
          emit(state.copyWith(
            isScanning: false,
            scanProgress: 1.0,
            statusMessage: 'Subnet scan completed.',
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isScanning: false,
        errorMessage: 'Failed to initiate sweep: $e',
      ));
    }
  }

  Future<void> _auditGateway() async {
    try {
      final report = await UpnpAuditor.auditGateway(state.rfContext.gatewayIp);
      emit(state.copyWith(
        upnpReport: report,
        rfContext: state.rfContext.copyWith(
          publicWanIp: report.externalWanIp,
          isDoubleNat: report.isDoubleNat,
          isCgnat: report.isCgnat,
        ),
      ));
    } catch (_) {}
  }

  /**
   * Deep camera verification for a specific host.
   */
  Future<void> verifyCameraHost(String ip) async {
    emit(state.copyWith(statusMessage: 'Verifying RTSP / ONVIF stream on $ip...'));
    final result = await CameraSentryEngine.inspectHost(ip);

    final updated = state.devices.map((d) {
      if (d.ip == ip) {
        if (result.isConfirmedCamera) {
          FieldFeedbackEngine.triggerCameraAlert();
        }
        return d.copyWith(
          isConfirmedCamera: result.isConfirmedCamera,
          isCamera: result.isConfirmedCamera || result.isSuspectedStream,
          cameraProtocol: result.protocol,
          vendor: result.isConfirmedCamera ? 'Surveillance Camera' : d.vendor,
        );
      }
      return d;
    }).toList();

    final score = CameraSentryEngine.calculateSafetyScore(
      totalDevices: updated.length,
      confirmedCameras: updated.where((d) => d.isConfirmedCamera).length,
      suspectedCameras: updated.where((d) => d.isCamera).length,
    );

    emit(state.copyWith(
      devices: updated,
      safetyScore: score,
      statusMessage: result.details,
    ));
  }

  /**
   * Performs targeted multi-port scan on selected device.
   */
  Future<void> scanPortsForSelectedDevice() async {
    final dev = state.selectedDevice;
    if (dev == null) return;

    emit(state.copyWith(isTargetedScanning: true));
    final openPorts = await SubnetDiscoveryEngine.scanTargetedPorts(dev.ip);

    final updated = dev.copyWith(openPorts: openPorts);
    final updatedList = state.devices.map((d) => d.ip == dev.ip ? updated : d).toList();

    emit(state.copyWith(
      selectedDevice: updated,
      devices: updatedList,
      targetedPorts: openPorts,
      isTargetedScanning: false,
    ));
  }
}
