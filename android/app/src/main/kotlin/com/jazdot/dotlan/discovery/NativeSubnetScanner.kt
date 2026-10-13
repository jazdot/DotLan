package com.jazdot.dotlan.discovery

import kotlinx.coroutines.*
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit
import java.net.InetSocketAddress
import java.net.Socket
import java.net.ConnectException

data class HostProbeResult(
    val ip: String,
    val isAlive: Boolean,
    val openPorts: List<Int>,
    val latencyMs: Double
)

/**
 * High-performance bounded coroutines socket scanner.
 * 
 * Accurately identifies active hosts via both TCP Established handshakes
 * and TCP RST (ConnectException: Connection refused) affirmative indicators.
 */
class NativeSubnetScanner {
    private val probePorts = intArrayOf(80, 443, 445, 139, 22, 8080, 554, 62078)
    private val socketTimeoutMs = 120
    private val concurrencySemaphore = Semaphore(128)

    suspend fun sweepSubnet(
        targetIps: List<String>,
        onHostFound: (HostProbeResult) -> Unit
    ) = coroutineScope {
        val jobs = targetIps.map { ip ->
            launch(Dispatchers.IO) {
                concurrencySemaphore.withPermit {
                    val result = probeHost(ip)
                    if (result.isAlive) {
                        onHostFound(result)
                    }
                }
            }
        }
        jobs.joinAll()
    }

    private fun probeHost(ip: String): HostProbeResult {
        val openPorts = mutableListOf<Int>()
        var isAlive = false
        val startTime = System.nanoTime()
        var latencyMs = 0.0

        for (port in probePorts) {
            try {
                Socket().use { socket ->
                    socket.connect(InetSocketAddress(ip, port), socketTimeoutMs)
                    isAlive = true
                    openPorts.add(port)
                    if (latencyMs == 0.0) {
                        latencyMs = (System.nanoTime() - startTime) / 1_000_000.0
                    }
                }
            } catch (e: ConnectException) {
                // Affirmative Proof: A TCP RST was received from an alive host!
                isAlive = true
                if (latencyMs == 0.0) {
                    latencyMs = (System.nanoTime() - startTime) / 1_000_000.0
                }
            } catch (_: Exception) {
                // Timeout or unroutable
            }

            if (isAlive && openPorts.isNotEmpty()) {
                break
            }
        }

        return HostProbeResult(
            ip = ip,
            isAlive = isAlive,
            openPorts = openPorts,
            latencyMs = if (latencyMs > 0.0) latencyMs else 1.5
        )
    }
}
