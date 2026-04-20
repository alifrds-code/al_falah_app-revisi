import 'package:flutter/material.dart';

/// PLACEHOLDER FCM (Firebase Cloud Messaging)
/// Mengikuti instruksi, Push Notification tidak dapat berjalan penuh secara lokal 
/// tanpa konfigurasi key Firebase dan APN Apple yang nyata.
/// Class ini mendemonstrasikan letak logika notifikasi dipanggil.
class FcmPlaceholder {
  /// Di panggil saat aplikasi pertama startup
  static Future<void> initNotification(BuildContext context) async {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('Firebase Cloud Messaging (FCM) Service Initialized.'),
    //     duration: Duration(seconds: 2),
    //   ),
    // );
    
    // LOGIKA SEHARUSNYA:
    // 1. FirebaseMessaging.instance.requestPermission();
    // 2. String? token = await FirebaseMessaging.instance.getToken();
    // 3. FirebaseMessaging.onMessage.listen((RemoteMessage message) { ... });
  }

  /// Dipanggil untuk subscribe ke topic tertentu, misal topic: kelas_X
  static Future<void> subscribeToTopic(String topicName) async {
    print('FCM: Successfully subscribed to topic $topicName');
    // FirebaseMessaging.instance.subscribeToTopic(topicName);
  }

  /// Dipanggil untuk unsubscribe dari topic
  static Future<void> unsubscribeFromTopic(String topicName) async {
    print('FCM: Successfully unsubscribed from topic $topicName');
    // FirebaseMessaging.instance.unsubscribeFromTopic(topicName);
  }
}
