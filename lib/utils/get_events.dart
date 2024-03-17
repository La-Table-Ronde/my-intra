import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_intra/utils/fetch_data.dart';

import '../model/event.dart';

Future<List<Event>> getEventsForDate(
    DateTime startDate, DateTime endDate) async {
  final url =
      "https://intra.epitech.eu/planning/load?format=json&start=${startDate.year}-${startDate.month}-${startDate.day}&end=${endDate.year}-${endDate.month}-${endDate.day}";
  final responseString = await fetchData(url);
  final value = jsonDecode(responseString);
  final List<Event> events = [];
  if (responseString.length == 2) {
    return events;
  }
  if (value == null) {
    return events;
  }
  for (var event in value) {
    Event evt = Event.fromJson(event);
    if (evt.eventRegistered == "present" ||
        evt.eventRegistered == "absent" ||
        evt.eventRegistered == "registered") {
      if (evt.rdvGroupRegistered != null) {
        List<String> times = evt.rdvGroupRegistered!.split("|");
        String startTime = times[0];
        String endTime = times[1];
        evt.start = DateTime.parse(startTime);
        evt.end = DateTime.parse(endTime);
      }
      if (evt.rdvIndivRegistered != null && evt.rdvGroupRegistered != null) {
        List<String> times = evt.rdvGroupRegistered!.split("|");
        String startTime = times[0];
        String endTime = times[1];
        evt.start = DateTime.parse(startTime);
        evt.end = DateTime.parse(endTime);
      } else if (evt.rdvIndivRegistered != null) {
        debugPrint("rdvIndivRegistered is not null");
        debugPrint(evt.actiTitle);
        debugPrint(evt.toString());
      }
      events.add(evt);
    }
  }
  return events;
}
