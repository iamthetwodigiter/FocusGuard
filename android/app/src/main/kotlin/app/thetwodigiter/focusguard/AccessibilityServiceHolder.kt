package app.thetwodigiter.focusguard

object AccessibilityServiceHolder {
    private var service: FocusGuardAccessibilityService? = null

    fun setService(svc: FocusGuardAccessibilityService) {
        service = svc
    }

    fun getService(): FocusGuardAccessibilityService? = service

    fun clearService() {
        service = null
    }
}
