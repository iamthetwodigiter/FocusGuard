package app.thetwodigiter.focusguard

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat

object ServiceNotificationManager {
    private const val TAG = "ServiceNotification"
    private const val CHANNEL_ID = "focusguard_service_channel"
    private const val NOTIFICATION_ID = 1001
    
    /**
     * Creates and manages the notification channel for Android 8.0+
     */
    fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "FocusGuard Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows FocusGuard service status and blocked apps count"
                enableVibration(false)
                setShowBadge(false)
            }
            
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
            Log.d(TAG, "✅ Notification channel created")
        }
    }
    
    /**
     * Shows or updates the persistent notification
     */
    fun showServiceNotification(
        context: Context,
        blockedAppsCount: Int,
        blockedBrowsersCount: Int,
        isSessionActive: Boolean
    ) {
        try {
            createNotificationChannel(context)
            
            val totalBlocked = blockedAppsCount + blockedBrowsersCount
            val statusText = if (isSessionActive) {
                "🔴 Session Active"
            } else {
                "🟢 Service Ready"
            }
            
            val contentTitle = "FocusGuard - $statusText"
            val contentText = "Blocked: $totalBlocked app${if (totalBlocked != 1) "s" else ""}"
            
            // Intent to open the app when notification is clicked
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            val notification = NotificationCompat.Builder(context, CHANNEL_ID)
                .setContentTitle(contentTitle)
                .setContentText(contentText)
                .setSmallIcon(android.R.drawable.ic_dialog_info) // Use system icon as fallback
                .setContentIntent(pendingIntent)
                .setAutoCancel(false)
                .setOngoing(true) // Make it persistent (can't be swiped away)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
                .build()
            
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            try {
                notificationManager.notify(NOTIFICATION_ID, notification)
                Log.d(TAG, "✅ Notification updated: $contentTitle - $contentText")
            } catch (e: SecurityException) {
                Log.e(TAG, "⚠️ Notification permission not granted yet: ${e.message}")
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error showing notification: ${e.message}", e)
        }
    }
    
    /**
     * Updates only the blocked apps count in the notification
     */
    fun updateBlockedCount(
        context: Context,
        blockedAppsCount: Int,
        blockedBrowsersCount: Int,
        isSessionActive: Boolean
    ) {
        // Show or update the notification with new count
        showServiceNotification(context, blockedAppsCount, blockedBrowsersCount, isSessionActive)
    }
    
    /**
     * Dismisses the notification
     */
    fun dismissNotification(context: Context) {
        try {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.cancel(NOTIFICATION_ID)
            Log.d(TAG, "✅ Notification dismissed")
        } catch (e: Exception) {
            Log.e(TAG, "Error dismissing notification: ${e.message}")
        }
    }
}
