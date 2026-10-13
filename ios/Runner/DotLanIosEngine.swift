import Foundation
import Network

/**
 * Apple Network.framework Bonjour Browser Engine.
 * 
 * Enumerates mDNS services on local iOS networks without requiring
 * private multicast entitlements.
 */
@available(iOS 13.0, *)
public class DotLanIosEngine: NSObject {
    private var browser: NWBrowser?
    private var discoveredEndpoints: [String: String] = [:]

    public func startBonjourScan(serviceType: String = "_http._tcp", onFound: @escaping ([String: Any]) -> Void) {
        let descriptor = NWBrowser.Descriptor.bonjour(type: serviceType, domain: "local.")
        let parameters = NWParameters()

        browser = NWBrowser(for: descriptor, using: parameters)

        browser?.browseResultsChangedHandler = { results, changes in
            for result in results {
                switch result.endpoint {
                case .service(let name, let type, let domain, _):
                    onFound([
                        "name": name,
                        "type": type,
                        "domain": domain
                    ])
                default:
                    break
                }
            }
        }

        browser?.start(queue: .main)
    }

    public func stopScan() {
        browser?.cancel()
        browser = nil
    }
}
