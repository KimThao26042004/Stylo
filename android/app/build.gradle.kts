// SỬA: Thay thế cú pháp Groovy bằng cú pháp Kotlin DSL: id("...")
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.fashion_shop"

    // SỬA LỖI 1: Gán String thay vì Int
    compileSdkVersion = "android-34"

    defaultConfig {
        applicationId = "com.example.fashion_shop"
        minSdkVersion(23)
        targetSdkVersion(34)
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Cấu hình bắt buộc cho Kotlin/Android
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }
}

flutter {
    // SỬA LỖI 2: Gán String thay vì File
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.22")
}