package app.thetwodigiter.focusguard

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.util.Log

class FocusGuardAccessibilityService : AccessibilityService() {
    private var lastProcessedPackage = ""
    private val logBuffer = mutableListOf<String>()
    private var overlayManager: BlockOverlayManager? = null
    private var currentBlockedApp: String? = null
    private var blockedApps: Set<String> = emptySet()
    private var blockedBrowsers: Set<String> = emptySet()
    private var isSessionActive: Boolean = false

    companion object {
        private const val TAG = "FocusGuardService"
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val BLOCKED_APPS_KEY = "flutter.nativeBlockedApps"
        private const val BLOCKED_BROWSERS_KEY = "flutter.nativeBlockedBrowsers"
        private const val SESSION_ACTIVE_KEY = "flutter.nativeSessionActive"
        private const val BLOCK_SYSTEM_APPS_KEY = "flutter.blockSystemApps"
        
        // System packages that should NEVER be blocked
        private val SYSTEM_WHITELIST = setOf(
            // Core Android System
            "com.android.systemui",
            "com.android.settings",
            "com.android.launcher",
            "com.android.launcher3",
            "com.android.phone",
            "com.android.dialer",
            "com.android.contacts",
            "com.android.mtp",
            "com.android.providers",
            "com.android.emergency",
            "com.android.vending",           // Play Store
            "android",
            
            // Google System Apps
            "com.google.android.apps.nexuslauncher",
            "com.google.android.dialer",
            "com.google.android.contacts",
            "com.google.android.gsf",
            "com.google.android.gms",
            "com.google.android.setupwizard",
            
            // Samsung
            "com.samsung.android.oneui.home",      // OneUI Launcher
            "com.samsung.android.app.launcher",
            "com.sec.android.app.launcher",
            "com.samsung.android.dialer",
            "com.android.incallui",
            "com.samsung.android.incall",
            "com.samsung.android.messaging",
            "com.samsung.android.contacts",
            "com.samsung.android.app.contacts",
            "com.samsung.android.bixby",
            "com.samsung.android.setting",
            "com.samsung.android.emergencymode",
            
            // Xiaomi / MIUI
            "com.miui.home",                       // MIUI Launcher
            "com.mi.android.globallauncher",
            "com.android.thememanager",
            "com.miui.securitycenter",
            "com.xiaomi.micloud",
            "com.xiaomi.finddevice",
            "com.miui.systemAdSolution",
            "com.android.mms",                     // Messages
            "com.miui.powerkeeper",
            "com.miui.securityadd",
            
            // Huawei / EMUI
            "com.huawei.android.launcher",
            "com.huawei.systemmanager",
            "com.huawei.android.thememanager",
            "com.huawei.phoneservice",
            "com.huawei.android.hsf",
            "com.huawei.hwid",
            "com.huawei.himovie",
            
            // OnePlus / OxygenOS
            "net.oneplus.launcher",
            "net.oneplus.odm",
            "com.oneplus.security",
            "com.oneplus.account",
            "com.oneplus.backuprestore",
            
            // Oppo / ColorOS
            "com.oppo.launcher",
            "com.coloros.safecenter",
            "com.coloros.gamespace",
            "com.oppo.contacts",
            
            // Vivo / FuntouchOS
            "com.vivo.launcher",
            "com.iqoo.secure",
            "com.bbk.launcher2",
            "com.vivo.safecenter",
            
            // Realme
            "com.realme.launcher",
            "com.coloros.phonenoareainquire",
            
            // Motorola
            "com.motorola.launcher3",
            "com.motorola.setupwizard",
            
            // Nokia
            "com.evenwell.nps",
            "com.hmdglobal.app.activation",
            
            // Sony
            "com.sonymobile.home",
            "com.sonymobile.xperialounge",
            
            // LG
            "com.lge.launcher2",
            "com.lge.launcher3",
            "com.lge.smartworld",
            
            // Essential System Services
            "com.android.nfc",
            "com.android.bluetoot",
            "com.android.server.telecom",
            "com.qualcomm.qti",                    // Qualcomm services
            "com.mediatek",                        // MediaTek services
            "com.android.vending",                 // Play Store
            
            // Critical Google Apps
            "com.google.android.apps.maps",
            "com.google.android.calendar",
            "com.google.android.apps.docs",
            "com.google.android.gm",               // Gmail
            "com.google.android.apps.messaging",
        )
    }

    private var blockSystemApps: Boolean = false

    override fun onServiceConnected() {
        super.onServiceConnected()
        AccessibilityServiceHolder.setService(this)
        Log.w(TAG, "========================================")
        Log.w(TAG, "🚀 FocusGuard Accessibility Service CONNECTED!")
        
        // Initialize overlay manager
        overlayManager = BlockOverlayManager(this)
        Log.w(TAG, "✅ Overlay manager initialized")
        
        // Load blocked apps and session state on startup
        Log.w(TAG, "🔄 Loading initial blocked apps and session state...")
        loadBlockedApps()
        Log.w(TAG, "✅ Initial load complete")
        
        // Show persistent notification showing service is active
        updateServiceNotification()
        
        // Configure service programmatically for better compatibility
        val info = AccessibilityServiceInfo()
        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or 
                         AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
        info.flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                    AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
        info.notificationTimeout = 0
        
        serviceInfo = info
        Log.w(TAG, "✅ Service info configured programmatically")
        
        // Log the service info
        val currentInfo = serviceInfo
        Log.w(TAG, "📋 Service Info:")
        Log.w(TAG, "   - Event types: ${currentInfo?.eventTypes}")
        Log.w(TAG, "   - Feedback type: ${currentInfo?.feedbackType}")
        Log.w(TAG, "   - Flags: ${currentInfo?.flags}")
        Log.w(TAG, "   - Package names: ${currentInfo?.packageNames?.contentToString() ?: "ALL"}")
        
        Log.w(TAG, "========================================")
        loadBlockedApps()
        
        Log.e(TAG, "⚠️ WAITING FOR ACCESSIBILITY EVENTS...")
        Log.e(TAG, "⚠️ Try switching to another app now!")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED ||
            event?.eventType == AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED) {
            val packageName = event.packageName?.toString() ?: return
            
            // Skip if same package (avoid log spam)
            if (packageName == lastProcessedPackage) return
            lastProcessedPackage = packageName
            
            addLog("📱 Window changed to: $packageName")
            
            // Whitelist our own app to prevent infinite loop
            if (packageName == this.packageName) {
                addLog("⚪ Ignoring own app")
                Log.d(TAG, "Debug: Own app ignored")
                return
            }
            
            loadBlockedApps() // Reload blocked apps on each event to get latest data

            // Check if it's a system app that should never be blocked
            if (!blockSystemApps && isSystemApp(packageName)) {
                addLog("⚪ Ignoring system app: $packageName")
                Log.d(TAG, "Debug: System app ignored")
                return
            }

            // Always ignore core system packages from the whitelist regardless of setting
            if (SYSTEM_WHITELIST.contains(packageName)) {
                addLog("⚪ Ignoring core whitelist app: $packageName")
                return
            }
            
            val isBlocked = blockedApps.contains(packageName) || blockedBrowsers.contains(packageName)
            val shouldBlock = isSessionActive && isBlocked
            
            addLog("[Session: ${if(isSessionActive) "🔴 ON" else "⚪ OFF"}] [Blocked: $isBlocked] Package: $packageName")

            // Only block if session is active and package is in either blocked list
            if (shouldBlock) {
                val type = if (blockedBrowsers.contains(packageName)) "BROWSER" else "APP"
                addLog("🚫 BLOCKING $type: $packageName")
                Log.e(TAG, "BLOCKING $type: $packageName")
                blockApp(packageName)
            } else {
                Log.d(TAG, "Debug: Allowed $packageName")
            }
        }
    }
    
    private fun addLog(message: String) {
        val timestamp = java.text.SimpleDateFormat("HH:mm:ss").format(java.util.Date())
        val logEntry = "[$timestamp] $message"
        logBuffer.add(logEntry)
        
        // Keep only last 500 entries to prevent memory leak
        if (logBuffer.size > 500) {
            logBuffer.removeAt(0)
        }
        Log.i(TAG, message) // Still log to Android logs
    }
    
    fun getLogs(): List<String> = logBuffer.toList()
    
    fun addLogFromDart(message: String) {
        val timestamp = java.text.SimpleDateFormat("HH:mm:ss").format(java.util.Date())
        val logEntry = "[$timestamp] 📱 $message"
        logBuffer.add(logEntry)
        
        // Keep only last 500 entries to prevent memory leak
        if (logBuffer.size > 500) {
            logBuffer.removeAt(0)
        }
    }
    
    private fun isSystemApp(packageName: String): Boolean {
        // Core android prefixes
        val systemPrefixes = listOf(
            "com.android.",
            "android.",
            "com.google.android.gsf",
            "com.google.android.gms",
        )
        
        return systemPrefixes.any { packageName.startsWith(it) }
    }

    private fun blockApp(packageName: String) {
        // Prevent blocking the same app multiple times
        if (currentBlockedApp == packageName) return
        
        currentBlockedApp = packageName
        addLog("✨ Overlay shown for: $packageName")
        
        // Show overlay with return to work message
        overlayManager?.showBlockOverlay(packageName) {
            addLog("✅ User dismissed overlay, returned to home")
            
            // Go to home screen when user clicks OK
            performGlobalAction(GLOBAL_ACTION_HOME)
            
            // Reset current blocked app after a delay
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                currentBlockedApp = null
            }, 1000)
        }
    }

    private fun loadBlockedApps() {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        
        // Load blocked apps list (stored as JSON string)
        val blockedAppsJson = prefs.getString(BLOCKED_APPS_KEY, "[]") ?: "[]"
        blockedApps = parseBlockedApps(blockedAppsJson)
        
        // Load blocked browsers list (stored as JSON string)
        val blockedBrowsersJson = prefs.getString(BLOCKED_BROWSERS_KEY, "[]") ?: "[]"
        blockedBrowsers = parseBlockedApps(blockedBrowsersJson)
        
        // Load session active status
        isSessionActive = prefs.getBoolean(SESSION_ACTIVE_KEY, false)
        
        // Load block system apps preference
        blockSystemApps = prefs.getBoolean(BLOCK_SYSTEM_APPS_KEY, false)
        
        updateServiceNotification()
    }
    
    private fun updateServiceNotification() {
        ServiceNotificationManager.updateBlockedCount(
            this,
            blockedApps.size,
            blockedBrowsers.size,
            isSessionActive
        )
    }

    private fun parseBlockedApps(json: String): Set<String> {
        return try {
            if (json.isEmpty() || json == "[]") return emptySet()
            
            // Simple manual parsing
            val cleaned = json
                .replace("[", "")
                .replace("]", "")
                .replace("\"", "")
                .trim()
            
            if (cleaned.isEmpty()) return emptySet()
            
            cleaned.split(",")
                .map { it.trim() }
                .filter { it.isNotEmpty() }
                .toSet()
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing: ${e.message}")
            emptySet()
        }
    }

    override fun onInterrupt() {
        addLog("⚠️ Service Interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        overlayManager?.dismissOverlay()
        overlayManager = null
        ServiceNotificationManager.dismissNotification(this)
        AccessibilityServiceHolder.clearService()
        addLog("🔴 Service Destroyed")
    }
}
