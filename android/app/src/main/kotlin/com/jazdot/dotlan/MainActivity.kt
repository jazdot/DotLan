package com.jazdot.dotlan

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import com.jazdot.dotlan.discovery.MulticastLockManager
import com.jazdot.dotlan.discovery.NativeSubnetScanner
import com.jazdot.dotlan.discovery.UpnpIgdProber

/**
 * DotLan Android Main Activity & Native Bridge.
 * 
 * Handles MulticastLock lifecycle, native socket acceleration, and UPnP IGD telemetry.
 */
class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.jazdot.dotlan/discovery"
    private lateinit var multicastLockManager: MulticastLockManager
    private val subnetScanner = NativeSubnetScanner()
    private val upnpProber = UpnpIgdProber()
    private val activityScope = CoroutineScope(Dispatchers.Main + Job())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        multicastLockManager = MulticastLockManager(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "acquireMulticastLock" -> {
                    multicastLockManager.acquire()
                    result.success(true)
                }
                "releaseMulticastLock" -> {
                    multicastLockManager.release()
                    result.success(true)
                }
                "queryGatewayWanIp" -> {
                    val gatewayIp = call.argument<String>("gatewayIp") ?: "192.168.1.1"
                    activityScope.launch {
                        val res = upnpProber.queryGatewayWanIp(gatewayIp)
                        result.success(mapOf(
                            "wanIp" to res.wanIp,
                            "isUpnpActive" to res.isUpnpActive
                        ))
                    }
                }
                "sweepSubnetNative" -> {
                    val ips = call.argument<List<String>>("targetIps") ?: emptyList()
                    activityScope.launch {
                        val foundList = mutableListOf<Map<String, Any>>()
                        subnetScanner.sweepSubnet(ips) { host ->
                            foundList.add(mapOf(
                                "ip" to host.ip,
                                "isAlive" to host.isAlive,
                                "openPorts" to host.openPorts,
                                "latencyMs" to host.latencyMs
                            ))
                        }
                        result.success(foundList)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        multicastLockManager.release()
        activityScope.cancel()
        super.onDestroy()
    }
}
