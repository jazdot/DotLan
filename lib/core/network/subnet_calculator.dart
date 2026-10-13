/**
 * Subnet & CIDR Calculation Engine.
 * 
 * Computes network bounds, host ranges, and slices large enterprise /16 or /8
 * networks safely to prevent socket descriptor exhaustion.
 */
class SubnetCalculation {
  final String networkAddress;
  final String broadcastAddress;
  final String firstHost;
  final String lastHost;
  final int totalHosts;
  final int cidrPrefix;
  final bool isEnterpriseSubnet;
  final List<String> targetIps;

  const SubnetCalculation({
    required this.networkAddress,
    required this.broadcastAddress,
    required this.firstHost,
    required this.lastHost,
    required this.totalHosts,
    required this.cidrPrefix,
    required this.isEnterpriseSubnet,
    required this.targetIps,
  });
}

class SubnetCalculator {
  /**
   * Converts an IPv4 string to a 32-bit integer.
   */
  static int ipToInt(String ip) {
    final parts = ip.split('.').map(int.parse).toList();
    return (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3];
  }

  /**
   * Converts a 32-bit integer to an IPv4 string.
   */
  static String intToIp(int value) {
    return '${(value >> 24) & 0xFF}.${(value >> 16) & 0xFF}.${(value >> 8) & 0xFF}.${value & 0xFF}';
  }

  /**
   * Converts netmask string to CIDR prefix length (e.g. 255.255.255.0 -> 24).
   */
  static int netmaskToPrefix(String netmask) {
    try {
      final maskInt = ipToInt(netmask);
      int count = 0;
      for (int i = 31; i >= 0; i--) {
        if ((maskInt & (1 << i)) != 0) {
          count++;
        } else {
          break;
        }
      }
      return count > 0 ? count : 24;
    } catch (_) {
      return 24;
    }
  }

  /**
   * Calculates subnet bounds and generates bounded scan list.
   */
  static SubnetCalculation calculate({
    required String localIp,
    String netmask = '255.255.255.0',
    int? overridePrefix,
  }) {
    final prefix = overridePrefix ?? netmaskToPrefix(netmask);
    final ipInt = ipToInt(localIp);
    final maskInt = prefix == 0 ? 0 : (~0 << (32 - prefix));

    final networkInt = ipInt & maskInt;
    final broadcastInt = networkInt | (~maskInt);

    final firstHostInt = networkInt + 1;
    final lastHostInt = broadcastInt - 1;
    final total = (lastHostInt >= firstHostInt) ? (lastHostInt - firstHostInt + 1) : 0;

    final isEnterprise = prefix < 23; // e.g. /22, /16, /8
    final List<String> targets = [];

    if (!isEnterprise && total <= 512) {
      // Standard /24 or /23 home/office subnet: sweep entire range
      for (int i = firstHostInt; i <= lastHostInt; i++) {
        targets.add(intToIp(i));
      }
    } else {
      // Large enterprise /16: slice immediate /24 neighborhood to guard file descriptors
      final baseOctets = localIp.split('.');
      final neighborhoodBase = '${baseOctets[0]}.${baseOctets[1]}.${baseOctets[2]}';
      for (int i = 1; i <= 254; i++) {
        targets.add('$neighborhoodBase.$i');
      }
    }

    return SubnetCalculation(
      networkAddress: intToIp(networkInt),
      broadcastAddress: intToIp(broadcastInt),
      firstHost: intToIp(firstHostInt),
      lastHost: intToIp(lastHostInt),
      totalHosts: total,
      cidrPrefix: prefix,
      isEnterpriseSubnet: isEnterprise,
      targetIps: targets,
    );
  }

  /**
   * Checks if an IP address belongs to RFC 1918 private space.
   */
  static bool isPrivateIp(String ip) {
    try {
      final parts = ip.split('.').map(int.parse).toList();
      if (parts[0] == 10) return true;
      if (parts[0] == 172 && (parts[1] >= 16 && parts[1] <= 31)) return true;
      if (parts[0] == 192 && parts[1] == 168) return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  /**
   * Checks if an IP belongs to RFC 6598 Carrier-Grade NAT (100.64.0.0/10).
   */
  static bool isCgnatIp(String ip) {
    try {
      final parts = ip.split('.').map(int.parse).toList();
      return parts[0] == 100 && (parts[1] >= 64 && parts[1] <= 127);
    } catch (_) {
      return false;
    }
  }
}
