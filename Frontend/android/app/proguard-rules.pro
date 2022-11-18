# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in ${SDK}/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}
-keepclassmembers class * extends com.google.protobuf.GeneratedMessageLite { *; }

## Flutter core
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.**  { *; }

## Flutter watch_connectivity
-keep class dev.rexios.watch_connectivity.** { *; }
-keep class dev.rexios.** { *; }

## Flutter vlc player
-keep class org.videolan.libvlc.** { *; }