# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# audio_service
-keep class com.ryanheise.** { *; }

# just_audio
-keep class com.google.android.exoplayer2.** { *; }

# Google Mobile Ads (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Keep all model classes (JSON serialization)
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Flutter Play Core stubs (deferred components not used — suppress R8 warnings)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# General Android
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-dontwarn okhttp3.**
-dontwarn okio.**
