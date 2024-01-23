import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> showNotificationsSettingsModal(BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            contentPadding: const EdgeInsets.all(16),
            insetPadding: const EdgeInsets.symmetric(horizontal: 0),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            content: SizedBox(
                width: 332,
                child: FutureBuilder(
                    future: SharedPreferences.getInstance(),
                    builder:
                        (context, AsyncSnapshot<SharedPreferences> snapshot) {
                      if (snapshot.hasData) {
                        int delay =
                            snapshot.data!.getInt("notifications_delay") ?? 5;
                        return StatefulBuilder(builder: (context, setState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                "Notifications settings",
                                style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              const SizedBox(height: 30),
                              Text(
                                "My Intra can alert you when an event is about to start. You can choose to be alerted 5, 10 or 15 minutes before the event starts.",
                                style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              const SizedBox(height: 30),
                              Text(
                                "Please chose the delay you want:",
                                style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              const SizedBox(height: 30),
                              RadioListTile(
                                title: const Text("5 minutes"),
                                value: 5,
                                groupValue: delay,
                                onChanged: (value) {
                                  snapshot.data!.setInt(
                                      "notifications_delay", value as int);
                                  delay = value;
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              ),
                              RadioListTile(
                                title: const Text("10 minutes"),
                                value: 10,
                                groupValue: delay,
                                onChanged: (value) {
                                  snapshot.data!.setInt(
                                      "notifications_delay", value as int);
                                  delay = value;
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              ),
                              RadioListTile(
                                title: const Text("15 minutes"),
                                value: 15,
                                groupValue: delay,
                                onChanged: (value) {
                                  snapshot.data!.setInt(
                                      "notifications_delay", value as int);
                                  delay = value;
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    })));
      });
}
