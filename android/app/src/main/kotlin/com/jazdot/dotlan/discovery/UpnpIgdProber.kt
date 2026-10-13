package com.jazdot.dotlan.discovery

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.HttpURLConnection
import java.net.URL

data class UpnpWanResult(
    val wanIp: String?,
    val isUpnpActive: Boolean
)

/**
 * Native Android UPnP IGD SOAP client for on-device WAN IP discovery.
 */
class UpnpIgdProber {
    suspend fun queryGatewayWanIp(gatewayIp: String, port: Int = 1900): UpnpWanResult = withContext(Dispatchers.IO) {
        val candidatePorts = intArrayOf(1900, 5000, 49152, 5555, 80)
        for (p in candidatePorts) {
            try {
                val url = URL("http://$gatewayIp:$p/ipc/control/wanipconnection")
                val conn = url.openConnection() as HttpURLConnection
                conn.connectTimeout = 500
                conn.readTimeout = 500
                conn.requestMethod = "POST"
                conn.setRequestProperty("SOAPAction", "\"urn:schemas-upnp-org:service:WANIPConnection:1#GetExternalIPAddress\"")
                conn.setRequestProperty("Content-Type", "text/xml; charset=\"utf-8\"")
                conn.doOutput = true

                val soapPayload = """<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <s:Body>
    <u:GetExternalIPAddress xmlns:u="urn:schemas-upnp-org:service:WANIPConnection:1"/>
  </s:Body>
</s:Envelope>""".toByteArray()

                conn.outputStream.use { it.write(soapPayload) }

                if (conn.responseCode == 200) {
                    val body = conn.inputStream.bufferedReader().use { it.readText() }
                    val regex = Regex("<NewExternalIPAddress>(.*?)</NewExternalIPAddress>")
                    val match = regex.find(body)
                    val ip = match?.groupValues?.getOrNull(1)?.trim()
                    if (!ip.isNullOrEmpty() && ip != "0.0.0.0") {
                        return@withContext UpnpWanResult(wanIp = ip, isUpnpActive = true)
                    }
                }
            } catch (_: Exception) {}
        }
        UpnpWanResult(wanIp = null, isUpnpActive = false)
    }
}
