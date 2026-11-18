# Flutter and sqflite ProGuard / R8 Rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**
-dontwarn io.flutter.**
-dontwarn com.google.android.play.core.**

-keepclassmembers class * extends io.flutter.plugin.common.MethodChannel$MethodCallHandler {
    <fields>;
    <methods>;
}
-keep class * implements io.flutter.plugin.common.PluginRegistry$PluginRegistrantCallback { *; }
