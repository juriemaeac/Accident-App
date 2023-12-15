// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:accidentapp/main.dart';
import 'package:accidentapp/views/notification/view_notification.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:http/http.dart' as http;

String messagingAPI =
    'AAAAr7AT9nA:APA91bHn8WIMoWnmoRd5mPUWU6NL2JPsz-h2lCS9BkVZayc_-_1may4sCYF-pVwXwXCZAQfVg1Pn_dLiYdASplatgydJOMtYKkmgDOYVwvtFCmoKDJu1qEHCNwpqZ-QfQWGYVEgrn8YX';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification!.title}');
  print('Body: ${message.notification!.body}');
  print('Data: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.defaultImportance,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    //get the transaction id from the notification
    final timestamp = message.data['timestamp'];

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => ViewNotification(
          timestamp: timestamp,
        ),
        settings: RouteSettings(
          arguments: message,
        ),
      ),
    );

    print("Transaction ID From API: $timestamp");
  }

  Future initLocalNotifications() async {
    //const iOS = IOSInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _localNotifications.initialize(
      settings,
      onSelectNotification: (payload) {
        final message = RemoteMessage.fromMap(jsonDecode(payload!));
        handleMessage(message);
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen(
      (message) {
        final notification = message.notification;
        if (notification == null) return;
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@drawable/ic_launcher',
              importance: _androidChannel.importance,
            ),
          ),
          payload: jsonEncode(message.toMap()),
        );
      },
    );
  }

  void sendPushMessage(
      String token, String title, String body, String timestamp) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$messagingAPI'
          },
          body: jsonEncode(
            <String, dynamic>{
              'notification': <String, dynamic>{
                'timestamp': timestamp,
                'title': title,
                'body': body,
                'android_channel_id': 'high_importance_channel_id',
              },
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                //'id': '1',
                'status': 'done',
                'timestamp': timestamp,
                'title': title,
                'body': body,
              },
              'to': token,
            },
          ));
      print('Sending notification...');
    } catch (e) {
      print(e);
    }
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final fCMToken = await _firebaseMessaging.getToken();
    print('==============CHECKING TOKEN================');
    print('Token: $fCMToken');
    print('============================================');
    //initialize notifications
    initPushNotifications();
    initLocalNotifications();
  }
}
