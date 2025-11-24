# UCrop + OkHttp fix
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# Retrofit (optional)
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

# UCrop library
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**
