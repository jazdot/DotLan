package com.jazdot.dotlan.discovery

import android.content.Context
import android.net.wifi.WifiManager

/**
 * Manages WifiManager.MulticastLock to prevent Android Wi-Fi NICs
 * from dropping mDNS and SSDP multicast packets during discovery.
 */
class MulticastLockManager(context: Context) {
    private val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager
    private var multicastLock: WifiManager.MulticastLock? = null

    @Synchronized
    fun acquire() {
        if (multicastLock == null && wifiManager != null) {
            try {
                multicastLock = wifiManager.createMulticastLock("DotLanMulticastLock").apply {
                    setReferenceCounted(true)
                    acquire()
                }
            } catch (_: Exception) {}
        }
    }

    @Synchronized
    fun release() {
        try {
            multicastLock?.let {
                if (it.isHeld) {
                    it.release()
                }
            }
        } catch (_: Exception) {}
        multicastLock = null
    }
}
