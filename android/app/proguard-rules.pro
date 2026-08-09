# sherpa-onnx (JNI)
-keep class com.k2fsa.sherpa.onnx.** { *; }
-keepclassmembers class com.k2fsa.sherpa.onnx.** { *; }

# ONNX Runtime (JNI)
-keep class ai.onnxruntime.** { *; }
-keepclassmembers class ai.onnxruntime.** { *; }

# Drift (runtime reflection for SQL)
-keep class drift.** { *; }
-keep class sqlite3.** { *; }

# Keep annotations
-keep @androidx.annotation.Keep class * { *; }

# Native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
