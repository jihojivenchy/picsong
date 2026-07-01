############################################
# ✅ 기본 보존 설정 (Flutter 필수)
############################################
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

-keepclassmembers class * {
    public void onMethodCall(io.flutter.plugin.common.MethodCall, io.flutter.plugin.common.MethodChannel$Result);
}

############################################
# ✅ AndroidX
############################################
-keep class androidx.** { *; }

############################################
# ✅ Firebase (firebase_core, firebase_messaging)
############################################
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

############################################
# ✅ Gson (flutter_secure_storage 내부 사용 가능)
############################################
-keep class com.google.gson.** { *; }
-keepattributes *Annotation*

############################################
# ✅ Dio (network)
############################################
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-keep class retrofit2.** { *; }
-dontwarn okhttp3.**
-dontwarn retrofit2.**
-dontwarn okio.**

############################################
# ✅ Glide, CachedNetworkImage 등 (Glide 내부 사용 가능성)
############################################
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**

############################################
# ✅ Your app package
############################################
-keep class com.max.picsong.** { *; }

############################################
# ✅ Kakao Login
############################################
-keep class com.kakao.** { *; }
-dontwarn com.kakao.**

############################################
# ✅ Naver Login
############################################
-keep class com.nhn.android.naverlogin.** { *; }
-dontwarn com.nhn.android.naverlogin.**
-keep public class com.navercorp.nid.** { public *; }
-dontwarn com.navercorp.nid.**

############################################
# ✅ Apple Login
############################################
-keep class com.aboutyou.dart_packages.sign_in_with_apple.** { *; }

############################################
# ✅ Image Picker, File Picker, WebView, InAppWebView
############################################
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keep class io.flutter.plugins.webviewflutter.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }

############################################
# ✅ Local Notifications
############################################
-keep class com.dexterous.flutterlocalnotifications.** { *; }

############################################
# ✅ Font assets
############################################
-keep class fonts.** { *; }

############################################
# ✅ 기타 플러그인 관련 예외 처리
############################################
-dontwarn org.codehaus.mojo.**
-dontwarn org.simpleframework.**


# Flutter Deferred Components 관련 R8 보호 규칙
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.tasks.**
