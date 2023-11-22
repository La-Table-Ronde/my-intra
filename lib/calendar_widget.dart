import 'package:flutter/material.dart';
import 'package:my_intra/model/event.dart';
import 'package:my_intra/utils/get_events.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getEventsForDate(DateTime.now()),
      builder: (context, AsyncSnapshot<List<Event>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data![index].actiTitle!),
                subtitle: Text(snapshot.data![index].titlemodule!),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
