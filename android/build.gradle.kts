plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.fashion_shop"

    // SỬA LỖI 1: Nâng lên 36 (Dạng Int) để tương thích với các plugin mới
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.fashion_shop"

        // SỬA LỖI: Nâng minSdk lên 24 theo yêu cầu của Flutter/Plugin
        minSdk = 24

        // SỬA LỖI: Nâng targetSdk lên ít nhất 35 để khớp với yêu cầu của androidx.activity
        targetSdk = 35

        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // Lưu ý: Trong thực tế bạn nên cấu hình signingConfig riêng cho bản release
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }
}

flutter {
    // SỬA LỖI 2: source phải là một File object, không phải String
    source = "../.."
}

dependencies {
    // Kotlin stdlib nên dùng bản tương thích với Kotlin plugin của bạn
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.22")
}