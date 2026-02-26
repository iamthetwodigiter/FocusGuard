# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Accessibility Service & Native Bridge
-keep class app.thetwodigiter.focusguard.** { *; }

# Hive
-keep class io.hive.** { *; }
-dontwarn io.hive.**
-keep class com.hive.** { *; }
-dontwarn com.hive.**

# AndroidX
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

# Common Android classes
-keep class android.view.accessibility.** { *; }
-keep class android.accessibilityservice.** { *; }
