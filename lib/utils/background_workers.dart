import 'dart:async';
import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:my_intra/model/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart'
    as webview_cookie;

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
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  await remoteConfig.setDefaults({
    "microsoft_login_url":
        "https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&client_id=e05d4149-1624-4627-a5ba-7472a39e43ab&redirect_uri=https%3A%2F%2Fintra.epitech.eu%2Fauth%2Foffice365&state=%2F&HSU=1&login_hint="
  });
  String microsoftUrl = remoteConfig.getString("microsoft_login_url");
  HeadlessInAppWebView? headlessWebView;
  Completer loadingCompleter = Completer();
  CookieManager cookieManager = CookieManager.instance();
  final webViewCookie = webview_cookie.WebviewCookieManager();
  final cookies =
      await webViewCookie.getCookies('https://login.microsoftonline.com/');
  final all = await webViewCookie.getCookies(null);
  final cookiesSts = await webViewCookie.getCookies('https://sts.epitech.eu');
  await cookieManager.deleteCookies(
      url: WebUri.uri(Uri.parse("https://intra.epitech.eu")));
  for (var cookie in cookies) {
    await cookieManager.setCookie(
        url: WebUri.uri(Uri.parse("login.microsoftonline.com")),
        name: cookie.name,
        value: cookie.value,
        isSecure: cookie.secure,
        isHttpOnly: cookie.httpOnly);
  }
  for (var cookie in cookiesSts) {
    await cookieManager.setCookie(
        url: WebUri.uri(Uri.parse("sts.epitech.eu")),
        name: cookie.name,
        value: cookie.value,
        isSecure: cookie.secure,
        isHttpOnly: cookie.httpOnly);
  }
  for (var cookie in all) {
    await cookieManager.setCookie(
        url: WebUri.uri(Uri.parse(cookie.domain!)),
        name: cookie.name,
        value: cookie.value,
        isSecure: cookie.secure,
        isHttpOnly: cookie.httpOnly);
  }
  headlessWebView = HeadlessInAppWebView(
    initialUrlRequest:
        URLRequest(url: WebUri.uri(Uri.parse("$microsoftUrl$email"))),
    onLoadStop: (controller, url) async {
      if (url == WebUri("https://intra.epitech.eu/")) {
        loadingCompleter.complete();
        var userCookie = await cookieManager.getCookies(
            url: WebUri.uri(Uri.parse("https://intra.epitech.eu/")));
        final prefs = await SharedPreferences.getInstance();
        Map<String, String?> cookies = {};
        for (var item in userCookie) {
          cookies[item.name] = item.value;
        }
        await prefs.setString("cookies", json.encode(cookies));
        if (kDebugMode) {
          print("cookies in back : $cookies");
        }
      }
    },
  );
  await headlessWebView.run();
  await loadingCompleter.future;
  await headlessWebView.dispose();
  var userCookie = await cookieManager.getCookie(
      url: WebUri.uri(Uri.parse("https://intra.epitech.eu")), name: "user");
  if (userCookie == null) {
    return;
  }
  prefs.setString("user", userCookie.value);
}
