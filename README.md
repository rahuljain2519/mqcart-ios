# mqcart-ios

The **iOS build** of the MQ Cart app.

This repo is a Flutter project that contains the same `lib/` application code as
[`mqcart-mobile`](https://github.com/rahuljain2519/mqcart-mobile) (the Android
app), configured and built for iOS only. It talks to the same Firebase backend
(`mqcart-prod`).

> **Kept in sync by hand.** Because the Dart code is duplicated, any change to
> screens / repositories / services / models must be applied to **both**
> `mqcart-mobile/lib/` and `mqcart-ios/lib/`. Only the platform folders differ
> (`android/` lives in mqcart-mobile, `ios/` here).

## What is already done in this repo

- `ios/` runner configured, bundle id **`com.mqcart.app.ios`**
- `Info.plist`: camera / photo-library usage strings, `remote-notification`
  background mode, `LSApplicationQueriesSchemes` for `tel` / `https` / `mailto`
- Display name **MQ Cart**, launcher-icon generation switched to iOS
  (`flutter_launcher_icons`, `remove_alpha_ios: true`)
- `push_notification_service.dart` labels FCM tokens `ios`, waits for the APNs
  token before asking for the FCM token
- Fresh version line `1.0.0+1` (independent of the Android version history)
- GitHub Actions workflow `ios_release.yml` — unsigned archive by default,
  signed + TestFlight path commented in

## What still has to be done (needs an Apple account + a Firebase change)

1. **Apple Developer Program** membership ($99/yr).
2. In App Store Connect: create the app record for `com.mqcart.app.ios`.
3. In the **Firebase console** (`mqcart-prod`): add an **iOS app** with bundle id
   `com.mqcart.app.ios`. Download its `GoogleService-Info.plist` into
   `ios/Runner/` (and add it to the Runner target in Xcode). Then either re-run
   `flutterfire configure` or paste the new `appId` / `iosClientId` into
   `lib/firebase_options.dart` (see the `TODO(ios-setup)` comment there).
4. **APNs Auth Key**: create a `.p8` key in the Apple Developer portal, upload it
   under Firebase → Project settings → Cloud Messaging → Apple app configuration.
   Without it, iOS devices never get an FCM token.
5. **Signing secrets** for CI — add these repo secrets and enable the commented
   steps in `ios_release.yml`:
   `APPLE_CERTIFICATE_BASE64`, `APPLE_CERTIFICATE_PASSWORD`,
   `APPLE_PROVISIONING_PROFILE_BASE64`, `APP_STORE_CONNECT_KEY_ID`,
   `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_KEY_BASE64`,
   `GOOGLE_SERVICE_INFO_PLIST_BASE64`.
6. Add an `ios/ExportOptions.plist` (method `app-store`, your team id) for
   `flutter build ipa`.

## Building

You cannot build iOS on Windows. Options:

- **GitHub Actions** (`ios_release.yml`) — push to `main`, download the archive
  from the run. Add signing secrets to get a TestFlight upload.
- **A Mac** — `flutter pub get && cd ios && pod install && cd ..` then
  `flutter build ipa` (or open `ios/Runner.xcworkspace` in Xcode).

`flutter analyze` runs anywhere and is wired into `flutter_ci.yml`.
