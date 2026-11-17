import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._();

  FirebaseService._();

  // REMOTE CONFIG

  String get welcomeMessage {
    try {
      final message = FirebaseRemoteConfig.instance.getString(
        'welcome_message',
      );

      return message.isEmpty ? 'Cố gắng hoàn thành nhé!' : message;
    } catch (_) {
      return 'Cố gắng hoàn thành nhé!';
    }
  }

  Future<void> initialize() async {
    try {
      final config = FirebaseRemoteConfig.instance;

      await config.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(minutes: 1),
        ),
      );

      await config.setDefaults({'welcome_message': 'Cố gắng hoàn thành nhé!'});

      await config.fetchAndActivate();
    } catch (error) {
      debugPrint('Remote Config: $error');
    }
  }

  // REALTIME DATABASE

  Future<void> updateActivity(String uid) async {
    try {
      await FirebaseDatabase.instance.ref('activity/$uid').update({
        'lastActive': ServerValue.timestamp,
      });
    } catch (error) {
      debugPrint('Realtime Database: $error');
    }
  }

  // GOOGLE ANALYTICS

  Future<void> logEvent(String name) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: name);
    } catch (error) {
      debugPrint('Analytics: $error');
    }
  }
}
