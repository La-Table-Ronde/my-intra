import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:html/parser.dart';
// ignore_for_file: public_member_api_docs

import 'package:my_intra/home.dart';
import 'package:my_intra/model/notifications.dart';
import 'package:my_intra/utils/check_for_events.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart'
    as webview_cookie;
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
          print("error : $e");
        }
      }
      return (true);
    }
    if (task == "check-events-task") {
      try {
        await checkForEvents();
      } catch (e) {
        if (kDebugMode) {
          print("error : $e");
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
            for (var item in gotCookies) {
              if (item.name == "user") {
                final prefs = await SharedPreferences.getInstance();
                prefs.setString("user", item.value);
                Workmanager().registerPeriodicTask(
                    "check-connection",
                    frequency: const Duration(days: 1),
                    "check-connection-task",
                    constraints:
                        Constraints(networkType: NetworkType.connected),
                    existingWorkPolicy: ExistingWorkPolicy.replace);
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomePageLoggedIn()),
                  );
                }
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
    return const Row(
      children: <Widget>[],
    );
  }
}

void onDidReceiveNotificationResponse(NotificationResponse details) {
  if (kDebugMode) {}
}

Future<void> setAllNotifsToSent() async {
  Completer loadingCompleter = Completer();
  final prefs = await SharedPreferences.getInstance();
  List<Notifications> list = [];
  String? data = prefs.getString("notifications");
  if (data != null) {
    final jsonList = json.decode(data) as List<dynamic>;
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
  await prefs
      .setString("notifications", jsonValue)
      .then((value) => loadingCompleter.complete());
  await loadingCompleter.future;
}

Future<void> setAllNotifsToRead() async {
  Completer loadingCompleter = Completer();
  final prefs = await SharedPreferences.getInstance();
  List<Notifications> list = [];
  String? data = prefs.getString("notifications");
  if (data != null) {
    final jsonList = json.decode(data) as List<dynamic>;
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
  await prefs
      .setString("notifications", jsonValue)
      .then((value) => loadingCompleter.complete());
  await loadingCompleter.future;
}

Future<void> getNewCookie() async {
  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString("email");
  if (email == null) {
    return;
  }
  HeadlessInAppWebView? headlessWebView;
  Completer loadingCompleter = Completer();
  CookieManager cookieManager = CookieManager.instance();
  final webViewCookie = webview_cookie.WebviewCookieManager();
  final cookies =
      await webViewCookie.getCookies('https://login.microsoftonline.com/');
  final all = await webViewCookie.getCookies(null);
  final cookiesSts = await webViewCookie.getCookies('https://sts.epitech.eu');
  await cookieManager.deleteCookie(
      url: Uri.parse("https://intra.epitech.eu"), name: "user");
  for (var cookie in cookies) {
    await cookieManager.setCookie(
        url: Uri.parse("login.microsoftonline.com"),
        name: cookie.name,
        value: cookie.value,
        isSecure: cookie.secure,
        isHttpOnly: cookie.httpOnly);
  }
  for (var cookie in cookiesSts) {
    await cookieManager.setCookie(
        url: Uri.parse("sts.epitech.eu"),
        name: cookie.name,
        value: cookie.value,
        isSecure: cookie.secure,
        isHttpOnly: cookie.httpOnly);
  }
  for (var cookie in all) {
    await cookieManager.setCookie(
        url: Uri.parse(cookie.domain!),
        name: cookie.name,
        value: cookie.value,
        isSecure: cookie.secure,
        isHttpOnly: cookie.httpOnly);
  }
  headlessWebView = HeadlessInAppWebView(
    initialUrlRequest: URLRequest(
        url: Uri.parse(
            "https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&client_id=e05d4149-1624-4627-a5ba-7472a39e43ab&redirect_uri=https%3A%2F%2Fintra.epitech.eu%2Fauth%2Foffice365&state=%2F&HSU=1&login_hint=$email")),
    onLoadStop: (controller, url) async {
      if (url == Uri.parse("https://intra.epitech.eu/")) {
        loadingCompleter.complete();
        var userCookie = await cookieManager.getCookie(
            url: Uri.parse("https://intra.epitech.eu/"), name: "user");
        prefs.setString("user", userCookie?.value);
      }
    },
  );
  await headlessWebView.run();
  await loadingCompleter.future;
  await headlessWebView.dispose();
  var userCookie = await cookieManager.getCookie(
      url: Uri.parse("https://intra.epitech.eu"), name: "user");
  if (userCookie == null) {
    return;
  }
  prefs.setString("user", userCookie.value);
}
