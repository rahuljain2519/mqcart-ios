import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PushNotificationService {
  static Future<void> initSellerPush() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final messaging = FirebaseMessaging.instance;
    final platform = Platform.isIOS ? 'ios' : 'android';

    // Request permission (iOS + Android 13+)
    if (Platform.isIOS || Platform.isAndroid) {
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // On iOS the FCM token is only available once APNs has handed us a device
    // token — needs an APNs Auth Key uploaded in Firebase → Cloud Messaging.
    if (Platform.isIOS) {
      await messaging.getAPNSToken();
    }

    final token = await messaging.getToken();
    if (token == null) return;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    // ✅ Store token in users collection.
    // `fcmToken` is the legacy single-device field; `fcmTokens` is a
    // { token: platform } map so a seller can be reachable on app + web at once.
    await userRef.set(
      {
        'fcmToken': token,
        'fcmTokens': {token: platform},
      },
      SetOptions(merge: true),
    );

    // 🔄 Token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      userRef.set(
        {
          'fcmToken': newToken,
          'fcmTokens': {newToken: platform},
        },
        SetOptions(merge: true),
      );
    });
  }
}
