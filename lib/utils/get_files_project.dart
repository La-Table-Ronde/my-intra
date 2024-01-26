import 'dart:convert';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:my_intra/model/files.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<List<File>> getFilesForProject(String projectUrl) async {
  final prefs = await SharedPreferences.getInstance();
  String? user = prefs.getString("user");
  final url = projectUrl;
  final client = http.Client();
  final cookieValue = user;
  final request = http.Request('GET', Uri.parse(url));
  request.headers['cookie'] = "user=$cookieValue";
  final metric =
      FirebasePerformance.instance.newHttpMetric(url, HttpMethod.Get);
  await metric.start();
  final response = await client.send(request);
  if (response.statusCode != 200) {
    return Future.error("Error${response.statusCode}");
  }
  final responseBytes = await response.stream.toList();
  final responseString =
      utf8.decode(responseBytes.expand((byte) => byte).toList());
  final value = jsonDecode(responseString);
  metric
    ..responseContentType = response.headers['content-type']
    ..responsePayloadSize = responseBytes.length
    ..requestPayloadSize = utf8.encode(request.body).length
    ..httpResponseCode = response.statusCode
    ..putAttribute("request_payload", request.body);
  await metric.stop();
  final List<File> files = [];
  for (var file in value) {
    if (file['type'] == 'd') {
      List<File> filesInFolder = await getFilesForProject(
          "https://intra.epitech.eu/${file['fullpath']}/?format=json");
      files.addAll(filesInFolder);
      continue;
    }
    files.add(File.fromJson(file));
  }
  return files;
}
