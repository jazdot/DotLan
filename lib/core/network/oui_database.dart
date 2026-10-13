/**
 * IEEE Organizationally Unique Identifier (OUI) Offline Hardware Vendor Database.
 * 
 * Provides instantaneous, 100% on-device vendor resolution for MAC addresses
 * and NetBIOS Unit IDs without sending queries to the internet.
 */
class OuiDatabase {
  static final Map<String, String> _ouiPrefixTable = {
    // Apple
    '00:17:F2': 'Apple, Inc.',
    '00:1C:B3': 'Apple, Inc.',
    '00:26:BB': 'Apple, Inc.',
    '04:0C:CE': 'Apple, Inc.',
    'AC:BC:32': 'Apple, Inc.',
    'F0:18:98': 'Apple, Inc.',
    'F4:0F:24': 'Apple, Inc.',
    '3C:06:30': 'Apple, Inc.',
    '70:35:60': 'Apple, Inc.',
    '90:27:E4': 'Apple, Inc.',
    'A4:83:E7': 'Apple, Inc.',
    'DC:A9:04': 'Apple, Inc.',
    'FC:FC:48': 'Apple, Inc.',
    'F8:FF:C2': 'Apple, Inc.',

    // Samsung
    '00:12:47': 'Samsung Electronics',
    '18:E2:C2': 'Samsung Electronics',
    '34:14:5F': 'Samsung Electronics',
    '50:85:69': 'Samsung Electronics',
    '84:25:DB': 'Samsung Electronics',
    'A0:0B:BA': 'Samsung Electronics',
    'C4:73:1E': 'Samsung Electronics',
    'E8:50:8B': 'Samsung Electronics',
    'FC:A1:3E': 'Samsung Electronics',

    // Google / Nest
    '08:9E:08': 'Google, Inc.',
    '3C:5A:37': 'Google, Inc.',
    '54:60:09': 'Google, Inc.',
    'F4:F5:DB': 'Google, Inc.',
    'D8:6C:63': 'Google, Inc.',
    'A4:77:33': 'Google, Inc.',
    '18:B4:30': 'Nest Labs (Google)',
    '64:16:66': 'Nest Labs (Google)',

    // Amazon / Ring
    '00:FC:8B': 'Amazon Technologies',
    '44:65:0D': 'Amazon Technologies',
    '68:54:5A': 'Amazon Technologies',
    'AC:63:BE': 'Amazon Technologies',
    'FC:65:DE': 'Amazon Technologies',
    '34:D2:70': 'Amazon Technologies',
    '50:F5:DA': 'Amazon Technologies',
    '94:9F:3E': 'Ring Inc. (Amazon)',

    // Cameras / Surveillance (Crucial for Camera Sentry)
    '44:19:B6': 'Hikvision Digital',
    'C0:56:E3': 'Hikvision Digital',
    '00:18:AE': 'Hikvision Digital',
    'BC:54:36': 'Hikvision Digital',
    '28:57:BE': 'Hikvision Digital',
    '3C:EF:8C': 'Dahua Technology',
    '4C:11:BF': 'Dahua Technology',
    '90:02:A9': 'Dahua Technology',
    'E0:50:8B': 'Dahua Technology',
    '00:40:8C': 'Axis Communications',
    '2C:AA:8E': 'Wyze Labs, Inc.',
    '8C:85:90': 'Reolink Digital',
    '48:EA:63': 'Amcrest Technologies',
    'A0:92:08': 'Foscam Technologies',

    // Smart IoT & Microcontrollers
    '24:62:AB': 'Espressif (ESP32/ESP8266)',
    '24:0A:C4': 'Espressif (ESP32/ESP8266)',
    '30:AE:A4': 'Espressif (ESP32/ESP8266)',
    '84:0D:8E': 'Espressif (ESP32/ESP8266)',
    'A4:CF:12': 'Espressif (ESP32/ESP8266)',
    'EC:FA:BC': 'Espressif (ESP32/ESP8266)',
    '7C:DF:A1': 'Espressif (ESP32/ESP8266)',
    '10:2C:6B': 'Tuya Smart (IoT)',
    '50:8A:06': 'Tuya Smart (IoT)',
    '70:89:76': 'Tuya Smart (IoT)',
    'D8:1F:12': 'Tuya Smart (IoT)',
    '00:17:88': 'Philips Lighting (Hue)',
    'EC:B5:FA': 'Philips Lighting (Hue)',
    'B8:27:EB': 'Raspberry Pi Foundation',
    'DC:A6:32': 'Raspberry Pi Foundation',
    'E4:5F:01': 'Raspberry Pi Foundation',
    '28:CD:C1': 'Raspberry Pi Foundation',

    // Entertainment / Audio / Smart TVs
    '00:0E:58': 'Sonos, Inc.',
    '48:A6:B8': 'Sonos, Inc.',
    '5C:AA:FD': 'Sonos, Inc.',
    '78:28:CA': 'Sonos, Inc.',
    'B8:E9:37': 'Sonos, Inc.',
    '00:01:4A': 'Sony Corporation',
    '00:13:15': 'Sony Corporation',
    'F8:46:1C': 'Sony Corporation',
    'FC:0F:E6': 'Sony Corporation',
    '00:26:AB': 'Roku, Inc.',
    'AC:AE:19': 'Roku, Inc.',
    'DC:3A:5E': 'Roku, Inc.',
    '00:19:FB': 'LG Electronics',
    '20:3D:66': 'LG Electronics',
    'A8:23:FE': 'LG Electronics',

    // Network Gear & Gateways
    '00:00:0C': 'Cisco Systems',
    '00:01:42': 'Cisco Systems',
    '00:18:BA': 'Cisco Systems',
    'AC:8B:A9': 'Cisco Systems',
    '00:1D:0F': 'TP-Link Corporation',
    '50:C7:BF': 'TP-Link Corporation',
    '60:32:B1': 'TP-Link Corporation',
    'C0:C9:E3': 'TP-Link Corporation',
    'F4:F2:6D': 'TP-Link Corporation',
    '00:14:D1': 'Netgear Inc.',
    '20:E5:2A': 'Netgear Inc.',
    '9C:3D:CF': 'Netgear Inc.',
    '00:1F:C6': 'ASUSTek Computer',
    '1C:87:2C': 'ASUSTek Computer',
    'F0:79:59': 'ASUSTek Computer',
    '04:18:D6': 'Ubiquiti Networks',
    '78:8A:20': 'Ubiquiti Networks',
    'B4:FB:E4': 'Ubiquiti Networks',
    'F0:9F:C2': 'Ubiquiti Networks',

    // Printers
    '00:01:E6': 'HP Inc.',
    '00:1E:0B': 'HP Inc.',
    '10:60:4B': 'HP Inc.',
    '64:51:06': 'HP Inc.',
    '00:80:77': 'Brother Industries',
    '30:05:5C': 'Brother Industries',
    '00:00:85': 'Canon Inc.',
    '18:0C:AC': 'Canon Inc.',
  };

  /**
   * Resolves a manufacturer name from a given MAC address or OUI prefix.
   */
  static String resolveVendor(String? macAddress) {
    if (macAddress == null || macAddress.length < 8) {
      return 'Unknown Vendor';
    }

    final normalized = macAddress
        .toUpperCase()
        .replaceAll('-', ':')
        .replaceAll('.', ':');

    final parts = normalized.split(':');
    if (parts.length >= 3) {
      final prefix = '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:${parts[2].padLeft(2, '0')}';
      if (_ouiPrefixTable.containsKey(prefix)) {
        return _ouiPrefixTable[prefix]!;
      }
    }

    return 'Generic Network Device';
  }

  /**
   * Checks if an OUI belongs to a surveillance camera manufacturer.
   */
  static bool isKnownCameraManufacturer(String? macAddress) {
    final vendor = resolveVendor(macAddress);
    return vendor.contains('Hikvision') ||
           vendor.contains('Dahua') ||
           vendor.contains('Axis') ||
           vendor.contains('Wyze') ||
           vendor.contains('Reolink') ||
           vendor.contains('Amcrest') ||
           vendor.contains('Foscam');
  }
}
