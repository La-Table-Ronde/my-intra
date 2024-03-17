import 'dart:convert';
import 'dart:io';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> fetchData(String url) async {
  final prefs = await SharedPreferences.getInstance();
  String? cookies = prefs.getString("cookies");
  if (cookies == null) {
    return Future.error("No cookies");
  }
  Map<String, String> cookieMap = {};
  jsonDecode(cookies).forEach((key, value) {
    cookieMap[key] = value;
  });
  HttpClient client = HttpClient();
  HttpClientRequest clientRequest = await client.getUrl(Uri.parse(url));
  clientRequest.cookies.addAll(cookieMap.entries
      .map((e) => Cookie(e.key, e.value))
      .toList(growable: false));
  final metric =
      FirebasePerformance.instance.newHttpMetric(url, HttpMethod.Get);
  await metric.start();
  HttpClientResponse response = await clientRequest.close();
  final stringData = await response.transform(utf8.decoder).join();
  metric
    ..responseContentType = response.headers.contentType.toString()
    ..responsePayloadSize = utf8.encode(stringData).length
    ..requestPayloadSize = utf8.encode("").length
    ..httpResponseCode = response.statusCode
    ..putAttribute("request_payload", stringData);

  await metric.stop();
  if (response.statusCode != 200) {
    return Future.error("Error${response.statusCode}");
  }
  return stringData;
}

Future<HttpClientResponse> postData(String url, Map<String, String>? body) async {
  final prefs = await SharedPreferences.getInstance();
  String? cookies = prefs.getString("cookies");
  if (cookies == null) {
    return Future.error("No cookies");
  }
  Map<String, String> cookieMap = {};
  jsonDecode(cookies).forEach((key, value) {
    cookieMap[key] = value;
  });
  HttpClient client = HttpClient();
  HttpClientRequest clientRequest = await client.postUrl(Uri.parse(url));
  clientRequest.cookies.addAll(cookieMap.entries
      .map((e) => Cookie(e.key, e.value))
      .toList(growable: false));
  clientRequest.headers.contentType = ContentType.json;
  clientRequest.write(jsonEncode(body));
  final metric =
      FirebasePerformance.instance.newHttpMetric(url, HttpMethod.Post);
  await metric.start();
  HttpClientResponse response = await clientRequest.close();
  final stringData = await response.transform(utf8.decoder).join();
  metric
    ..responseContentType = response.headers.contentType.toString()
    ..responsePayloadSize = utf8.encode(stringData).length
    ..requestPayloadSize = utf8.encode(jsonEncode(body)).length
    ..httpResponseCode = response.statusCode
    ..putAttribute("request_payload", jsonEncode(body));

  await metric.stop();
  return response;
}

Future<List<int>> fetchBytes (String url) async {
  final prefs = await SharedPreferences.getInstance();
  String? cookies = prefs.getString("cookies");
  if (cookies == null) {
    return Future.error("No cookies");
  }
  Map<String, String> cookieMap = {};
  jsonDecode(cookies).forEach((key, value) {
    cookieMap[key] = value;
  });
  HttpClient client = HttpClient();
  HttpClientRequest clientRequest = await client.getUrl(Uri.parse(url));
  clientRequest.cookies.addAll(cookieMap.entries
      .map((e) => Cookie(e.key, e.value))
      .toList(growable: false));
  final metric =
      FirebasePerformance.instance.newHttpMetric(url, HttpMethod.Get);
  await metric.start();
  HttpClientResponse response = await clientRequest.close();
  final bytes = await response.expand((byte) => byte).toList();

  await metric.stop();
  if (response.statusCode != 200) {
    return Future.error("Error${response.statusCode}");
  }
  return bytes;
}