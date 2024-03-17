import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Uint8List> fetchImage(String url) async {
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
  HttpClientResponse response = await clientRequest.close();
  final bytes = await consolidateHttpClientResponseBytes(response);
  if (response.statusCode != 200) {
    return Future.error("Error${response.statusCode}");
  }
  return bytes;
}
