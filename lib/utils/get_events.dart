import 'dart:convert';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:my_intra/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../model/event.dart';

Future<List<Event>> getEventsForDate(DateTime date) async {
  final prefs = await SharedPreferences.getInstance();
  String? user = prefs.getString("user");
  final url =
      "https://intra.epitech.eu/planning/load?format=json&start=${date.year}-${date.month}-${date.day}&end=${date.year}-${date.month}-${date.day}";
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
  debugPrint(responseBytes.toString());
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
  final List<Event> events = [];
  for (var event in value) {
    print(event);
    events.add(Event.fromJson(event));
  }
  return events;
}
