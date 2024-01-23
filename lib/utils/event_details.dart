import 'package:flutter/material.dart';
import 'package:my_intra/model/event.dart';

Future<void> showEventDetailsModal(Event event, BuildContext context) async {
  return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(event.actiTitle ?? "No title"),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Module: ${event.titlemodule}"),
                Text("Type: ${event.typeTitle}"),
                Text("Location: ${event.room?["code"] ?? "No location"}"),
                Text(
                    "Starts at : ${event.start.hour.toString().padLeft(2, '0')}:${event.start.minute.toString().padLeft(2, '0')}"),
                Text(
                    "Ends at : ${event.end.hour.toString().padLeft(2, '0')}:${event.end.minute.toString().padLeft(2, '0')}"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
