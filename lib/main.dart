import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:html/parser.dart';
// ignore_for_file: public_member_api_docs

import 'package:my_intra/home.dart';
import 'package:my_intra/utils/background_workers.dart';
import 'package:my_intra/utils/check_for_events.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:workmanager/workmanager.dart';

import 'globals.dart' as globals;

// #enddocregion platform_imports
Completer uploadCompleter = Completer();

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();
    if (task == "check-notifications-task") {
      final notifs = await getNotifications(false);
      for (var notification in notifs) {
        if (notification.read == false && notification.notifSent == false) {
          final prefs = await SharedPreferences.getInstance();
          var notifsSentList = prefs.getStringList("notifsSentList");
          if (notifsSentList != null) {
            if (notifsSentList.contains(notification.id)) {
              break;
            }
            notifsSentList.add(notification.id);
          } else {
            notifsSentList = [];
            notifsSentList.add(notification.id);
          }
          const AndroidNotificationDetails androidNotificationDetails =
              AndroidNotificationDetails('alerts', 'Alerts Notifications',
                  channelDescription:
                      'Notifications for the alerts of the Intra',
                  importance: Importance.defaultImportance,
                  styleInformation: BigTextStyleInformation(''),
                  priority: Priority.defaultPriority,
                  ticker: 'ticker');
          const NotificationDetails notificationDetails =
              NotificationDetails(android: androidNotificationDetails);
          prefs.setStringList("notifsSentList", notifsSentList);
          await globals.flutterLocalNotificationsPlugin.show(
              int.parse(notification.id),
              'New notification !',
              parseFragment(notification.title).text,
              notificationDetails,
              payload: 'alert-notif');
        }
      }
      await setAllNotifsToSent();
      return (true);
    }
    if (task == "check-connection-task") {
      try {
        await getNewCookie();
      } catch (e) {
        if (kDebugMode) {
          print("error 1 : $e");
        }
      }
      return (true);
    }
    if (task == "check-events-task") {
      try {
        await checkForEvents();
      } catch (e) {
        if (kDebugMode) {
          print("error 2 : $e");
        }
      }
      return (true);
    }
    return (false);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('notif');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await globals.flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  runApp(MaterialApp(
      // standard dark theme
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomePage()));
}

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
            final prefs = await SharedPreferences.getInstance();
            Map<String, String?> cookies = {};
            for (var item in gotCookies) {
              cookies[item.name] = item.value;
            }
            await prefs.setString("cookies", json.encode(cookies));
            if (kDebugMode) {
              print("cookies : $cookies");
            }
            if (cookies.containsKey("user")) {
              if (Platform.isAndroid) {
                Workmanager().registerPeriodicTask(
                    "check-connection",
                    frequency: const Duration(days: 1),
                    "check-connection-task",
                    constraints:
                        Constraints(networkType: NetworkType.connected),
                    existingWorkPolicy: ExistingWorkPolicy.replace);
              } else if (Platform.isIOS) {
                Workmanager().registerOneOffTask(
                    "check-connection", "check-connection-task");
              }
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomePageLoggedIn()),
                );
              }
            }
          },
          onWebResourceError: (var error) {
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
      ..loadRequest(Uri.parse('https://intra.epitech.eu'), headers: {
        "User-Agent":
            "Mozilla/5.0 (Linux; Android 10; SM-G960F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.181 Mobile Safari/537.36"
      });

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
      floatingActionButton: helpBtn(),
    );
  }

  Widget helpBtn() {
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
    return const Row(
      children: <Widget>[],
    );
  }
}

void onDidReceiveNotificationResponse(NotificationResponse details) {
  if (kDebugMode) {}
}

