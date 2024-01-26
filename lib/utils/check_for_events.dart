import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:html/parser.dart';
import 'package:my_intra/utils/get_events.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_intra/globals.dart' as globals;

Future<bool> checkForEvents() async {
  var sharedPrefs = await SharedPreferences.getInstance();
  int delay = sharedPrefs.getInt("notifications_delay") ?? 5;
  var alertedEvents = sharedPrefs.getStringList("alerted_events") ?? [];
  DateTime now = DateTime.now();
  var events = await getEventsForDate(now, now);
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('alerts', 'Alerts Notifications',
          channelDescription: 'Notifications for the alerts of the Intra',
          importance: Importance.defaultImportance,
          styleInformation: BigTextStyleInformation(''),
          priority: Priority.defaultPriority,
          ticker: 'ticker');
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  for (var event in events) {
    String codeEvt = event.codeevent!.replaceAll("event-", "");
    if (event.start.difference(now).inMinutes > delay) {
      continue;
    }
    if (alertedEvents.contains(codeEvt)) {
      continue;
    }
    await globals.flutterLocalNotificationsPlugin.show(
        int.parse(codeEvt),
        'Activity starts in ${event.start.difference(now).inMinutes} minutes',
        parseFragment(event.actiTitle).text,
        notificationDetails,
        payload: 'alert-notif');
    alertedEvents.add(codeEvt);
  }
  await sharedPrefs.setStringList("alerted_events", alertedEvents);
  debugPrint(alertedEvents.toString());
  return true;
}
