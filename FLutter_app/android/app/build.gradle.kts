plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.example.smart_locker_app"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.smart_locker_app"
        minSdk = 21   // 🔥 REQUIRED FOR FCM
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
}

dependencies {
    implementation("com.google.firebase:firebase-messaging")
}

/* 🔥 GOOGLE SERVICES PLUGIN APPLY */
apply(plugin = "com.google.gms.google-services")