import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.bapenda.cekreklame"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.bapenda.cekreklame"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 👇 PERBAIKAN: Gunakan Class langsung karena sudah di-import di atas
    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        create("release") {
            val keystoreFile = file("upload-keystore.jks")
            storeFile = keystoreFile

            storePassword = System.getenv("KEYSTORE_PASSWORD") 
                ?: keystoreProperties["storePassword"] as String?
            
            keyAlias = System.getenv("KEY_ALIAS") 
                ?: keystoreProperties["keyAlias"] as String?
            
            keyPassword = System.getenv("KEY_PASSWORD") 
                ?: keystoreProperties["keyPassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isShrinkResources = true
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.gms:play-services-maps:18.1.0") 
    implementation("androidx.exifinterface:exifinterface:1.3.3")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}