// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:html/parser.dart';
// ignore_for_file: public_member_api_docs

import 'package:my_intra/home.dart';
import 'package:my_intra/model/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:workmanager/workmanager.dart';

import 'globals.dart' as globals;
// #enddocregion platform_imports

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();
    if (task == "check-notifications-task") {
      final notifs = await getNotifications();
      for (var notification in notifs) {
        if (notification.read == false && notification.notifSent == false) {
          const AndroidNotificationDetails androidNotificationDetails =
              AndroidNotificationDetails('alerts', 'Alerts Notifications',
                  channelDescription:
                      'Notifications for the alerts of the Intra',
                  importance: Importance.defaultImportance,
                  priority: Priority.defaultPriority,
                  ticker: 'ticker');
          const NotificationDetails notificationDetails =
              NotificationDetails(android: androidNotificationDetails);
          await globals.flutterLocalNotificationsPlugin.show(
              int.parse(notification.id),
              'New notification !',
              parseFragment(notification.title).text,
              notificationDetails,
              payload: 'alert-notif');
        }
      }
      setAllNotifsToSent();
    }
    if (task == "check-connection-task") {
      bool login = await checkUserLoggedIn();
      if (kDebugMode) {
        print("login ? $login");
      }
      if (!login) {
        final prefs = await SharedPreferences.getInstance();
        String? date = prefs.getString("date-login-notif");
        if (date != null) {
          DateTime fulldate = DateTime.now().subtract(Duration(days: 2));
          DateTime now = DateTime.now();
          DateTime lastSent = DateTime.parse(date);
          if (!lastSent.isAfter(fulldate)) {
            return Future.value(true);
          }
        } else {
          prefs.setString("date-login-notif", DateTime.now().toString());
        }
        const AndroidNotificationDetails androidNotificationDetails =
            AndroidNotificationDetails('background', 'Background Notifications',
                channelDescription: 'Notifications in the background',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker');
        const NotificationDetails notificationDetails =
            NotificationDetails(android: androidNotificationDetails);
        await globals.flutterLocalNotificationsPlugin.show(
            0,
            'You have been logged out',
            'Click on the notification to reconnect yourself to the app.',
            notificationDetails,
            payload: 'login-notif');
      }
    }
    return Future.value(true);
  });
}

Future<void> main() async {
  HttpClient.enableTimelineLogging = true;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final fcmToken = await FirebaseMessaging.instance.getToken();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('notif');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await globals.flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          false // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  runApp(MaterialApp(
      // standard dark theme
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: HomePage()));
}

String? _user;

class LoginIntra extends StatefulWidget {
  const LoginIntra({super.key});

  @override
  State<LoginIntra> createState() => _LoginIntraState();
}

class _LoginIntraState extends State<LoginIntra> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) async {
            final cookieManager = WebviewCookieManager();
            final gotCookies =
                await cookieManager.getCookies('https://intra.epitech.eu');
            for (var item in gotCookies) {
              if (item.name == "user") {
                final prefs = await SharedPreferences.getInstance();
                prefs.setString("user", item.value);
                _user = item.value;
                Workmanager().registerPeriodicTask(
                    "check-connection", "check-connection-task",
                    constraints:
                        Constraints(networkType: NetworkType.connected),
                    existingWorkPolicy: ExistingWorkPolicy.replace);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomePageLoggedIn()),
                );
                return;
              }
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse('https://intra.epitech.eu'));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: SafeArea(child: WebViewWidget(controller: _controller)),
      floatingActionButton: favoriteButton(),
    );
  }

  Widget favoriteButton() {
    return ElevatedButton(
      onPressed: () async {
        showDialogConnexionIntra(context);
      },
      child: const Text("Help"),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key, required this.webViewController});

  final WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[],
    );
  }
}

void onDidReceiveNotificationResponse(NotificationResponse details) {
  if (kDebugMode) {
    print(details);
  }
}

Future<void> setAllNotifsToSent() async {
  final prefs = await SharedPreferences.getInstance();
  List<Notifications> list = [];
  String? data = prefs.getString("notifications");
  if (data != null) {
    final jsonList = json.decode(data) as List<dynamic>;
    if (kDebugMode) {
      print("data list : " + json.decode(data).toString());
    }
    list = jsonList.map((jsonObj) => Notifications.fromJson(jsonObj)).toList();
  }
  for (var notification in list) {
    notification.notifSent = true;
  }
  List<Map<String, dynamic>> mapList = [];
  for (Notifications obj in list) {
    mapList.add(obj.toJson());
  }
  final jsonValue = json.encode(mapList);
  await prefs.setString("notifications", jsonValue);
}

Future<void> setAllNotifsToRead() async {
  final prefs = await SharedPreferences.getInstance();
  List<Notifications> list = [];
  String? data = prefs.getString("notifications");
  if (data != null) {
    final jsonList = json.decode(data) as List<dynamic>;
    if (kDebugMode) {
      print("data list : " + json.decode(data).toString());
    }
    list = jsonList.map((jsonObj) => Notifications.fromJson(jsonObj)).toList();
  }
  for (var notification in list) {
    notification.read = true;
  }
  List<Map<String, dynamic>> mapList = [];
  for (Notifications obj in list) {
    mapList.add(obj.toJson());
  }
  final jsonValue = json.encode(mapList);
  await prefs.setString("notifications", jsonValue);
}