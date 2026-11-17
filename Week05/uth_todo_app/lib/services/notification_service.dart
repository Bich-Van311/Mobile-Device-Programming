import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();

  NotificationService._();

  final navigatorMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static const vapidKey =
      'BK0twbRhCA03toKRK3yHTgnffyTCyJHVU8F550TMDM4V8QaODACl3_Dw7P-Ps8UGm4AQ3uKUzEDsX6I8hiDRfbI';

  void initialize() {
    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? 'UTH Todo';

      final body = message.notification?.body ?? 'Bạn có thông báo mới';

      navigatorMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('$title\n$body'),
          duration: const Duration(seconds: 5),
        ),
      );
    });
  }

  Future<String?> enableNotifications() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      return null;
    }

    final token = kIsWeb
        ? await messaging.getToken(vapidKey: vapidKey)
        : await messaging.getToken();

    return token;
  }
}
