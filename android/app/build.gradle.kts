plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.biometric_auth"
    compileSdk = flutter.compileSdkVersion   // Gunakan versi dari Flutter SDK

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17   // Java 17 diperlukan oleh local_auth v3
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.biometric_auth"
        minSdk = flutter.minSdkVersion      // minimum Android 4.3 (API 18)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}

dependencies {
    implementation("androidx.fragment:fragment-ktx:1.6.2")  // ← WAJIB untuk local_auth v3
}
