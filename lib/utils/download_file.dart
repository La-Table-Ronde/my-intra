import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:my_intra/globals.dart' as globals;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:open_file_plus/open_file_plus.dart';

Future<void> downloadFile(String fileUrl, String filename) async {
  final prefs = await SharedPreferences.getInstance();
  String? user = prefs.getString("user");
  final url = 'https://intra.epitech.eu/$fileUrl';
  final client = http.Client();
  final cookieValue = user;
  final request = http.Request('GET', Uri.parse(url));
  request.headers['cookie'] = "user=$cookieValue";
  final metric =
      FirebasePerformance.instance.newHttpMetric(url, HttpMethod.Get);
  await metric.start();
  final response = await client.send(request);
  final responseBytes = await response.stream.toList();
  if (response.statusCode != 200) {
    return Future.error("Error${response.statusCode}");
  }
  Directory? directory;
  try {
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      await getApplicationDocumentsDirectory();
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists())
        directory = await getExternalStorageDirectory();
    }
  } catch (err, stack) {
    FirebaseCrashlytics.instance.recordError(err, stack);
  }
  try {
    final file = File('${directory!.path}/my_intra/$filename');
    file.create(recursive: true);
    await file.writeAsBytes(responseBytes.expand((byte) => byte).toList());
    await OpenFile.open(file.path);
  } catch (err, stack) {
    FirebaseCrashlytics.instance.recordError(err, stack);
  }
}
