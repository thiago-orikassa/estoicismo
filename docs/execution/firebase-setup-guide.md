# Firebase Setup Guide — Aethor Push Notifications

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project** → name it `aethor` (or your preferred name)
3. Disable Google Analytics (not needed for push) or enable if desired
4. Click **Create project**

## 2. Register Android App

1. In Firebase Console → Project Settings → **Add app** → Android
2. Package name: `com.example.aethor_app` (match `applicationId` in `app/android/app/build.gradle.kts`)
3. Download `google-services.json`
4. Place it at: `app/android/app/google-services.json`

## 3. Register iOS App

1. In Firebase Console → Project Settings → **Add app** → iOS
2. Bundle ID: match your Xcode project bundle identifier
3. Download `GoogleService-Info.plist`
4. Place it at: `app/ios/Runner/GoogleService-Info.plist`
5. Open Xcode, drag `GoogleService-Info.plist` into the Runner group

## 4. iOS: APNs Configuration

1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/authkeys/list)
2. Create an **APNs Key** (Apple Push Notification service):
   - Check **Apple Push Notifications service (APNs)**
   - Download the `.p8` file
   - Note the **Key ID** and **Team ID**
3. In Firebase Console → Project Settings → Cloud Messaging → iOS:
   - Upload the APNs key `.p8` file
   - Enter Key ID and Team ID

## 5. iOS: Xcode Push Capability

1. Open `app/ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** target → **Signing & Capabilities**
3. Click **+ Capability** → Add **Push Notifications**
4. Also add **Background Modes** → check **Remote notifications**

## 6. FlutterFire Configure (Optional)

If you want to use FlutterFire CLI for auto-configuration:

```bash
dart pub global activate flutterfire_cli
cd app
flutterfire configure --project=your-firebase-project-id
```

This generates `firebase_options.dart` automatically. If you prefer manual setup, the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files are sufficient.

## 7. Backend: FCM Service Account

For server-side push sending (`POST /v1/push/send`):

1. Firebase Console → Project Settings → **Service accounts**
2. Click **Generate new private key** → download JSON
3. Place it securely on your server
4. Set environment variable: `GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json`
5. The `/v1/push/send` endpoint currently runs in dry-run mode until a service account is configured

## 8. Verify

- Run the app on a device (not simulator for full push support)
- The app will request notification permission on first launch
- Check backend logs for `POST /v1/push-tokens` registration
- Check Firebase Console → Engage → Messaging to send a test notification
