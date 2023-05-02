// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore_for_file: public_member_api_docs

import 'package:my_intra/home.dart';
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
    print("task : " + task);
    if (task == "check-connection-task") {
      bool login = await checkUserLoggedIn();
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
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  Workmanager().registerOneOffTask("task-identifier", "simpleTask");
  print(fcmToken);
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

    // #docregion platform_features
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
    // #enddocregion platform_features

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
              print(item);
              if (item.name == "user") {
                final prefs = await SharedPreferences.getInstance();
                prefs.setString("user", item.value);
                _user = item.value;
                Workmanager().registerPeriodicTask(
                  "check-connection",
                  "check-connection-task",
                );
                Navigator.push(
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
  print(details);
}
