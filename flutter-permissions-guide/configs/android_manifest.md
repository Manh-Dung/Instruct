# Android Manifest Configuration

File: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.your_app">

    <!-- ========== BASIC PERMISSIONS ========== -->
    <!-- Location permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

    <!-- Storage permissions (traditional - for Android 12 and below) -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

    <!-- Storage permissions (granular - for Android 13+) -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

    <!-- Notification permissions (Android 13+) -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <!-- Other common permissions -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />

    <!-- ========== SPECIAL PERMISSIONS ========== -->
    <!-- These permissions open Settings instead of showing dialogs -->
    
    <!-- Manage external storage (all files access) -->
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
    
    <!-- System alert window (display over other apps) -->
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    
    <!-- Install packages (install unknown apps) -->
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
    
    <!-- Access notification policy (DND access) -->
    <uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY" />

    <application
        android:name="io.flutter.app.FlutterApplication"
        android:label="Your App Name"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

## ⚠️ Lưu ý về Android Versions

### Android 13+ (API 33)
- `READ_EXTERNAL_STORAGE` và `WRITE_EXTERNAL_STORAGE` bị deprecated
- Phải sử dụng granular permissions: `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO`
- `POST_NOTIFICATIONS` là bắt buộc

### Android 12+ (API 31)
- Location có 2 mức: "Precise" và "Approximate"
- User có thể chọn approximate location

### Android 10+ (API 29)
- `ACCESS_BACKGROUND_LOCATION` cần request riêng biệt
- Không thể request `locationAlways` trực tiếp

### Android 6+ (API 23)
- Runtime permissions được giới thiệu
- Cần request permissions trong code

## 🔧 Build.gradle Configuration

File: `android/app/build.gradle`

```gradle
android {
    compileSdkVersion 34
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    defaultConfig {
        applicationId "com.example.your_app"
        minSdkVersion 21  // Minimum for most permissions
        targetSdkVersion 34  // Latest stable
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}
```

## 📱 Target SDK Considerations

| Target SDK | Behavior Changes |
|------------|------------------|
| 34 (Android 14) | Enhanced notification permissions |
| 33 (Android 13) | Granular media permissions required |
| 31 (Android 12) | Approximate location introduced |
| 30 (Android 11) | Scoped storage enforced |
| 29 (Android 10) | Background location separate |
