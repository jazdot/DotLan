import '../../core/models/lan_device.dart';
import '../../core/models/wifi_rf_context.dart';
import '../../core/network/upnp_auditor.dart';
import '../../core/network/camera_sentry_engine.dart';

/**
 * State representing local subnet inventory and security posture.
 */
class LanState {
  final bool isScanning;
  final double scanProgress;
  final List<LanDevice> devices;
  final WifiRfContext rfContext;
  final UpnpAuditReport? upnpReport;
  final LanDevice? selectedDevice;
  final List<int> targetedPorts;
  final bool isTargetedScanning;
  final int safetyScore;
  final DeviceCategory? filterCategory;
  final String? statusMessage;
  final String? errorMessage;

  const LanState({
    this.isScanning = false,
    this.scanProgress = 0.0,
    this.devices = const [],
    this.rfContext = const WifiRfContext(),
    this.upnpReport,
    this.selectedDevice,
    this.targetedPorts = const [],
    this.isTargetedScanning = false,
    this.safetyScore = 100,
    this.filterCategory,
    this.statusMessage,
    this.errorMessage,
  });

  List<LanDevice> get filteredDevices {
    if (filterCategory == null) return devices;
    return devices.where((d) => d.category == filterCategory).toList();
  }

  int get confirmedCameraCount =>
      devices.where((d) => d.isConfirmedCamera).length;

  int get suspectedCameraCount =>
      devices.where((d) => d.isCamera && !d.isConfirmedCamera).length;

  LanState copyWith({
    bool? isScanning,
    double? scanProgress,
    List<LanDevice>? devices,
    WifiRfContext? rfContext,
    UpnpAuditReport? upnpReport,
    LanDevice? selectedDevice,
    List<int>? targetedPorts,
    bool? isTargetedScanning,
    int? safetyScore,
    DeviceCategory? filterCategory,
    bool clearFilter = false,
    String? statusMessage,
    String? errorMessage,
  }) {
    return LanState(
      isScanning: isScanning ?? this.isScanning,
      scanProgress: scanProgress ?? this.scanProgress,
      devices: devices ?? this.devices,
      rfContext: rfContext ?? this.rfContext,
      upnpReport: upnpReport ?? this.upnpReport,
      selectedDevice: selectedDevice ?? this.selectedDevice,
      targetedPorts: targetedPorts ?? this.targetedPorts,
      isTargetedScanning: isTargetedScanning ?? this.isTargetedScanning,
      safetyScore: safetyScore ?? this.safetyScore,
      filterCategory: clearFilter ? null : (filterCategory ?? this.filterCategory),
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
