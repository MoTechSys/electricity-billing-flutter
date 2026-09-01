# ── Flutter engine ────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ── printing / pdf (يستخدم PrintDocumentAdapter عبر reflection) ────────────
-keep class net.nfet.flutter.printing.** { *; }

# ── file_picker ───────────────────────────────────────────────────────────
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# ── share_plus ────────────────────────────────────────────────────────────
-keep class dev.fluttercommunity.plus.share.** { *; }

# ── sqlite3 / drift (JNI) ─────────────────────────────────────────────────
-keep class com.simolus.sqlite3_flutter_libs.** { *; }

# ── تنظيف عام ────────────────────────────────────────────────────────────
-dontwarn javax.annotation.**
-dontwarn org.jetbrains.annotations.**
