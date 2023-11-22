import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_intra/model/event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
bool adminMode = false;
List<DateTime> loadedDates = [];
List<Event> loadedEvents = [];