
# Migrate to grade 8.x.x

- Sửa lại file `android/settings.gradle`
```
pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        file("local.properties").withInputStream { properties.load(it) }
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
        return flutterSdkPath
    }()

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.1.4" apply false // gradle version
    id "org.jetbrains.kotlin.android" version "1.8.22" apply false // kotlin version
    id "com.google.gms.google-services" version "4.4.0" apply false
    id "com.google.firebase.crashlytics" version "2.9.9" apply false
}

include ":app"
```

### Xóa `buildscript` trong file `android/build.gradle`

![](https://github.com/minhson3756/admob/blob/main/migrate-gradle-8/img1.jpg?raw=true) 

### Cập nhật gradle version tại file `android/gradle/gradle-wrapper.properties`

![](https://github.com/minhson3756/admob/blob/main/migrate-gradle-8/img2.jpg?raw=true) 

### Cập nhật lại file  `android/app/build.gradle`

Sửa lại
```
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"
    id "com.google.firebase.crashlytics"
}
```

![](https://github.com/minhson3756/admob/blob/main/migrate-gradle-8/img6.png?raw=true) 

Thêm namespace
![](https://github.com/minhson3756/admob/blob/main/migrate-gradle-8/img3.png?raw=true) 

Xóa 3 dòng
![](https://github.com/minhson3756/admob/blob/main/migrate-gradle-8/img4.png?raw=true) 

### Androidmanifest
Xóa thuộc tính package ở `manifest`
![](https://github.com/minhson3756/admob/blob/main/migrate-gradle-8/img5.png?raw=true) 
