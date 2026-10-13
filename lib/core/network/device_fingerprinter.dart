import '../models/lan_device.dart';
import 'oui_database.dart';

/**
 * Multi-Signal Device Classifier & Fingerprinting Engine.
 * 
 * Synthesizes transport ports, mDNS service types, UPnP XML profiles,
 * NetBIOS identifiers, and OUI prefixes to categorize local endpoints.
 */
class DeviceFingerprinter {
  static DeviceCategory classify({
    required String ip,
    String? hostname,
    String? mac,
    String? mdnsName,
    String? upnpServer,
    String? netbiosName,
    List<int> openPorts = const [],
    List<String> services = const [],
    bool isGateway = false,
  }) {
    if (isGateway) return DeviceCategory.gateway;

    final lowerHost = (hostname ?? '').toLowerCase();
    final lowerMdns = (mdnsName ?? '').toLowerCase();
    final lowerUpnp = (upnpServer ?? '').toLowerCase();
    final lowerNetbios = (netbiosName ?? '').toLowerCase();
    final vendor = OuiDatabase.resolveVendor(mac).toLowerCase();

    // 1. Surveillance Cameras (Highest priority security classification)
    if (openPorts.contains(554) ||
        services.contains('RTSP') ||
        services.contains('ONVIF') ||
        OuiDatabase.isKnownCameraManufacturer(mac) ||
        lowerHost.contains('cam') ||
        lowerHost.contains('ipc') ||
        lowerHost.contains('hikvision') ||
        lowerHost.contains('dahua') ||
        lowerHost.contains('reolink') ||
        lowerHost.contains('wyze')) {
      return DeviceCategory.camera;
    }

    // 2. Network Printers
    if (openPorts.contains(9100) ||
        openPorts.contains(631) ||
        services.contains('_ipp._tcp') ||
        services.contains('_printer._tcp') ||
        lowerHost.contains('printer') ||
        lowerHost.contains('laserjet') ||
        lowerHost.contains('epson') ||
        lowerHost.contains('brother') ||
        vendor.contains('hp') ||
        vendor.contains('brother') ||
        vendor.contains('canon')) {
      return DeviceCategory.printer;
    }

    // 3. Entertainment & Media Sinks (Smart TV, Apple TV, Chromecast, Sonos)
    if (services.contains('_googlecast._tcp') ||
        services.contains('_airplay._tcp') ||
        services.contains('_spotify-connect._tcp') ||
        lowerHost.contains('appletv') ||
        lowerHost.contains('roku') ||
        lowerHost.contains('bravia') ||
        lowerHost.contains('sonos') ||
        lowerHost.contains('smarttv') ||
        lowerUpnp.contains('tv') ||
        lowerUpnp.contains('sonos') ||
        vendor.contains('sonos') ||
        vendor.contains('roku') ||
        vendor.contains('sony')) {
      return DeviceCategory.entertainment;
    }

    // 4. Smart Home & Embedded IoT
    if (services.contains('_matter._tcp') ||
        services.contains('_hap._tcp') ||
        vendor.contains('espressif') ||
        vendor.contains('tuya') ||
        vendor.contains('philips lighting') ||
        lowerHost.contains('esp_') ||
        lowerHost.contains('tasmota') ||
        lowerHost.contains('shelly') ||
        lowerHost.contains('hue') ||
        lowerHost.contains('nest')) {
      return DeviceCategory.iot;
    }

    // 5. Workstations / Servers / NAS
    if (openPorts.contains(445) ||
        openPorts.contains(139) ||
        openPorts.contains(22) ||
        lowerNetbios.isNotEmpty ||
        lowerHost.contains('desktop') ||
        lowerHost.contains('laptop') ||
        lowerHost.contains('macbook') ||
        lowerHost.contains('synology') ||
        lowerHost.contains('qnap') ||
        lowerHost.contains('server') ||
        lowerHost.contains('nas')) {
      return DeviceCategory.workstation;
    }

    // 6. Mobile Devices
    if (lowerHost.contains('iphone') ||
        lowerHost.contains('ipad') ||
        lowerHost.contains('android') ||
        lowerHost.contains('galaxy') ||
        lowerHost.contains('pixel')) {
      return DeviceCategory.mobile;
    }

    // Fallback to OUI vendor hints
    if (vendor.contains('apple') || vendor.contains('samsung') || vendor.contains('google')) {
      return DeviceCategory.mobile;
    }

    return DeviceCategory.unknown;
  }
}
