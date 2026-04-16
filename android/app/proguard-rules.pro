# Flutter/Dart
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Agora SDK
-keep class io.agora.** { *; }
-dontwarn io.agora.**
-keep class com.iris.** { *; }
-dontwarn com.iris.**

# Google Play Core (referenced by Flutter framework internally)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Google Mobile Services
-dontwarn com.google.android.gms.**
-keep class com.google.android.gms.** { *; }

# Kotlin Desugaring runtime
-dontwarn com.google.devtools.build.android.desugar.runtime.**

# Supabase / Ktor
-keep class io.ktor.** { *; }
-dontwarn io.ktor.**

# OkHttp
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# General
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep class * { @com.google.gson.annotations.SerializedName <fields>; }
