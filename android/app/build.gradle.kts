import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.steambun.steam_bun_timer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.steambun.steam_bun_timer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // 只打包 arm64 — 省去 x86_64/armeabi-v7a 的原生库（sherpa-onnx onnxruntime 各 ~20MB）
        ndk {
            abiFilters += "arm64-v8a"
        }
    }

    buildTypes {
        release {
            // 正式签名 — 本地用 key.properties，CI 用环境变量
            // 局部变量名必须避开 SigningConfig 的属性名，否则 Kotlin 解析为 val 赋值
            val ksPath = System.getenv("KEYSTORE_PATH")
            val ksPwd = System.getenv("KEYSTORE_PASSWORD")
            val ksAlias = System.getenv("KEY_ALIAS") ?: "steam-bun"
            val ksKeyPwd = System.getenv("KEY_PASSWORD")

            signingConfig = signingConfigs.create("release") {
                if (ksPath != null) {
                    storeFile = file(ksPath)
                    storePassword = ksPwd
                    keyAlias = ksAlias
                    keyPassword = ksKeyPwd
                } else {
                    // 本地构建：读取 key.properties
                    val props = Properties()
                    val propsFile = rootProject.file("key.properties")
                    if (propsFile.exists()) {
                        props.load(propsFile.inputStream())
                        storeFile = file(props["storeFile"] as String)
                        storePassword = props["storePassword"] as String
                        keyAlias = props["keyAlias"] as String
                        keyPassword = props["keyPassword"] as String
                    } else {
                        // 兜底：用 debug 签名（仅本地开发时）
                        storeFile = signingConfigs.getByName("debug").storeFile
                        storePassword = "android"
                        keyAlias = "androiddebugkey"
                        keyPassword = "android"
                    }
                }
            }

            // R8 全量优化 — 代码压缩 + 资源压缩
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
