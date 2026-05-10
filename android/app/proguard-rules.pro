# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Isar
-keep class dev.isar.** { *; }
-keep class com.isar.** { *; }
-dontwarn dev.isar.**

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# Google Fonts / HTTP
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
