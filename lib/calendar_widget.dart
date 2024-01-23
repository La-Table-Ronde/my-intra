import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_intra/model/event.dart';
import 'package:my_intra/notifications_settings.dart';
import 'package:my_intra/utils/event_details.dart';
import 'package:my_intra/utils/get_events.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'globals.dart' as globals;

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].start;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].end;
  }

  @override
  String getSubject(int index) {
    return appointments![index].actiTitle;
  }

  @override
  Color getColor(int index) {
    return const Color(0xFF7293E1);
  }

  @override
  String getLocation(int index) {
    return appointments![index].instanceLocation ?? "";
  }

  @override
  Future<void> handleLoadMore(DateTime startDate, DateTime endDate) async {
    final List<Event> events = [];
    for (var date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(const Duration(days: 1))) {
      if (globals.loadedDates.contains(date)) {
        continue;
      }
      List<Event> tmpEvents =
          await getEventsForDate(date, date).onError((error, stackTrace) {
        FirebaseCrashlytics.instance.recordError(error, stackTrace);
        return [];
      });
      events.addAll(tmpEvents);
      globals.loadedDates.add(date);
    }
    appointments!.addAll(events);
    notifyListeners(CalendarDataSourceAction.add, events);
  }
}

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  List<Event> events = globals.loadedEvents;
  List<Event> getEventsForDay(DateTime selectedDay, List<Event> events) {
    return events.where((event) {
      return event.start.day == selectedDay.day &&
          event.start.month == selectedDay.month &&
          event.start.year == selectedDay.year;
    }).toList();
  }

  @override
  void dispose() {
    globals.loadedEvents = events;
    super.dispose();
  }
  // @override
  // void initState() {
  //   getEventsForDate(DateTime.now()).then((value) {
  //     setState(() {
  //       events = value;
  //     });
  //   });
  //   super.initState();
  // }

  Widget loadMoreWidget(
      BuildContext context, LoadMoreCallback loadMoreAppointments) {
    return FutureBuilder<void>(
      future: loadMoreAppointments(),
      builder: (context, snapshot) {
        return Container(
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        );
      },
    );
  }

  final controller = CalendarController();
  DateFormat dateFormat = DateFormat("MMMM yyyy");
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SfCalendar(
            view: CalendarView.week,
            dataSource: EventDataSource(events),
            scheduleViewSettings: const ScheduleViewSettings(
                monthHeaderSettings: MonthHeaderSettings(height: 75)),
            scheduleViewMonthHeaderBuilder: (context, details) {
              var formattedDate = dateFormat.format(details.date);
              return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7293E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  width: details.bounds.width,
                  height: 150,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ));
            },
            viewHeaderStyle: const ViewHeaderStyle(
              dayTextStyle: TextStyle(
                color: Color(0xFF7293E1),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              dateTextStyle: TextStyle(
                color: Color(0xFF7293E1),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            headerStyle: const CalendarHeaderStyle(
              textStyle: TextStyle(
                color: Color(0xFF7293E1),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            todayHighlightColor: const Color(0xFF7293E1),
            loadMoreWidgetBuilder: loadMoreWidget,
            initialSelectedDate: DateTime.now(),
            initialDisplayDate: DateTime.now(),
            appointmentTimeTextFormat: "HH:mm",
            allowViewNavigation: true,
            showNavigationArrow: true,
            firstDayOfWeek: 1,
            timeSlotViewSettings: const TimeSlotViewSettings(
              timeIntervalHeight: 100,
              timeIntervalWidth: 400,
              timeInterval: Duration(minutes: 30),
              timeFormat: "HH:mm",
            ),
            allowedViews: const [
              CalendarView.day,
              CalendarView.week,
              CalendarView.schedule
            ],
            onSelectionChanged: (details) {
              // setState(() {
              //   events = getEventsForDay(details.date!, events);
              // });
            },
            onTap: (details) {
              if (details.appointments == null ||
                  details.appointments!.isEmpty) {
                return;
              }
              showEventDetailsModal(details.appointments![0], context);
            },
            controller: CalendarController(),
            appointmentBuilder: (context, calendarAppointmentDetails) {
              final Event event = calendarAppointmentDetails.appointments.first;
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: event.typeCode == "rdv"
                      ? Colors.red
                      : event.typeCode == "tp"
                          ? Colors.green
                          : Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                width: calendarAppointmentDetails.bounds.width,
                height: calendarAppointmentDetails.bounds.height,
                child: Column(
                  children: [
                    Flexible(
                      child: Text(
                        event.actiTitle ?? "No title",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      event.instanceLocation ?? "",
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await showNotificationsSettingsModal(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF7293E1),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              child: const Text("Notifications settings"),
            ),
          ),
        ),
      ],
    );
    // return FutureBuilder(
    //   future: getEventsForDate(DateTime.now()),
    //   builder: (context, AsyncSnapshot<List<Event>> snapshot) {
    //     if (snapshot.hasData) {
    //       events = getEventsForDay(_focusedDay, snapshot.data!);
    //       return Container(
    //           child: );
    //     } else if (snapshot.hasError) {
    //       return Text(snapshot.error.toString());
    //     }
    //     return const Center(child: CircularProgressIndicator());
    //   },
    // );
  }
}
