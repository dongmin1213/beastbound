## Flutter-specific ProGuard rules

# Keep Flutter engine
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# flutter_soloud native bindings
-keep class com.ryanheise.** { *; }

# Play Core (deferred components) — suppress R8 missing class errors
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Fix R8 XmlPullParser conflict (kxml2 vs android.content.res.XmlResourceParser)
-dontwarn org.xmlpull.v1.**
-keep class org.xmlpull.v1.** { *; }
