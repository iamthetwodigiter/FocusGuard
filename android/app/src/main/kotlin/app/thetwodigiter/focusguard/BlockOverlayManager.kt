package app.thetwodigiter.focusguard

import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView

class BlockOverlayManager(private val context: Context) {
    
    companion object {
        private const val TAG = "BlockOverlay"
    }
    
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var isShowing = false
    
    fun showBlockOverlay(blockedAppName: String, onDismiss: () -> Unit) {
        if (isShowing) {
            Log.d(TAG, "Overlay already showing, ignoring")
            return
        }
        
        try {
            Log.d(TAG, "Creating block overlay for: $blockedAppName")
            
            windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            
            // Inflate the overlay layout
            val inflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
            overlayView = inflater.inflate(R.layout.block_overlay, null)
            
            // Set the message
            val messageText = overlayView?.findViewById<TextView>(R.id.block_message)
            messageText?.text = "This application is restricted to help you stay in the flow.\n\nYou're doing great!"
            
            // Setup OK button
            val okButton = overlayView?.findViewById<Button>(R.id.ok_button)
            okButton?.setOnClickListener {
                Log.d(TAG, "OK button clicked, dismissing overlay")
                dismissOverlay()
                onDismiss()
            }
            
            // Setup window parameters
            val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_SYSTEM_ALERT
            }
            
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                layoutFlag,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                        WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                PixelFormat.TRANSLUCENT
            )
            
            params.gravity = Gravity.CENTER
            
            // Add the view to window
            windowManager?.addView(overlayView, params)
            isShowing = true
            
            Log.d(TAG, "✅ Overlay displayed successfully")
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error showing overlay: ${e.message}", e)
            isShowing = false
        }
    }
    
    fun dismissOverlay() {
        try {
            if (overlayView != null && isShowing) {
                windowManager?.removeView(overlayView)
                overlayView = null
                isShowing = false
                Log.d(TAG, "Overlay dismissed")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error dismissing overlay: ${e.message}")
        }
    }
}
