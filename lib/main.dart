import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devis_facture_gg_intervention/screens/home_dashboard_screen.dart';
import 'package:devis_facture_gg_intervention/screens/devis_form_screen.dart';
import 'package:devis_facture_gg_intervention/screens/notification_screen.dart';
import 'package:devis_facture_gg_intervention/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// 🔄 Handler pour notifications en arrière-plan
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("🔕 Notification reçue en background: ${message.notification?.title}");
  }
}

void setupFlutterNotifications() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel',
    'Notifications',
    description: 'Channel utilisé pour les notifications FCM',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  await dotenv.load();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    if (e.toString().contains('[core/duplicate-app]')) {
      if (kDebugMode) print("Firebase déjà initialisé.");
    } else {
      rethrow;
    }
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  setupFlutterNotifications();

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  String? token = await FirebaseMessaging.instance.getToken();
  if (kDebugMode) print("FCM Token : $token");

  final String? artisanUid = dotenv.env['UUID_USER'];
  final User? user = FirebaseAuth.instance.currentUser;

  if (artisanUid != null || user != null) {
    final uid = artisanUid ?? user!.uid;
    await FirebaseFirestore.instance.collection("config").doc("fcmToken").set({
      'token': token,
    }, SetOptions(merge: true));
    if (kDebugMode) print("✅ FCM token mis à jour dans Firestore pour $uid");
  } else {
    if (kDebugMode) {
      print("❌ Impossible de déterminer l'UID de l'utilisateur pour enregistrer le token");
    }
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) print('🔔 Notification foreground reçue: ${message.notification?.title}');
    showFlutterNotification(message);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GG Intervention Devis et Factures',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
      routes: {
        '/screens/devis_form': (context) => const DevisFormScreen(),
        '/screens/dashboard': (context) => const DashboardScreen(),
        '/screens/splashScreen': (context) => const SplashScreen(),
        '/screens/notificationScreen': (context) => const NotificationsScreen(),
      },
    );
  }
}
