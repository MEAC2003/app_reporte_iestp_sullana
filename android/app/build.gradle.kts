// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    
    // AGREGA EL PLUGIN DE GOOGLE SERVICES AQUÍ
    id("com.google.gms.google-services")

    // El plugin de Flutter debe ir después
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app_reporte_iestp_sullana"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17" // o JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.app_reporte_iestp_sullana"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Añade esta línea para habilitar multidex, a veces es necesario con Firebase
        multiDexEnabled = true 
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// AGREGA O MODIFICA TU BLOQUE DE DEPENDENCIAS ASÍ
dependencies {
    // Importa el Firebase BoM (Bill of Materials).
    // Esto maneja las versiones de las librerías de Firebase por ti.
    implementation(platform("com.google.firebase:firebase-bom:33.1.0")) // Usa la última versión del BoM

    // AÑADE LAS DEPENDENCIAS DE LOS PRODUCTOS DE FIREBASE QUE NECESITAS
    // Para notificaciones, necesitas firebase-messaging y firebase-analytics es recomendado.
    // No especifiques versiones aquí, el BoM se encarga.
    implementation("com.google.firebase:firebase-messaging-ktx")
    implementation("com.google.firebase:firebase-analytics-ktx")

    // Dependencia para multidex
    implementation("androidx.multidex:multidex:2.0.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}