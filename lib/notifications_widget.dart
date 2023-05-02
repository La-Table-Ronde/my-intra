import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart' show parseFragment;
import 'package:http/http.dart' as http;
import 'package:my_intra/home.dart';
import 'package:my_intra/model/notifications.dart';
import 'package:my_intra/model/profile.dart';
import 'package:my_intra/model/projects.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsWidget extends StatefulWidget {
  NotificationsWidget(
      {Key? key,
      required this.notifications,
      this.projects,
      required this.data})
      : super(key: key);
  Future<List<Projects>>? projects;
  final Profile data;
  Future<List<Notifications>>? notifications;

  @override
  State<NotificationsWidget> createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  @override
  void initState() {
    print("ici");
    super.initState();
  }

  @override
  void dispose() {
    if (widget.notifications != null) {
      widget.notifications!.then((value) => value.forEach((element) {
            element.read = true;
          }));
      List<Map<String, dynamic>> mapList = [];
      widget.notifications!.then((value) {
        for (Notifications obj in value) {
          mapList.add(obj.toJson());
          SharedPreferences.getInstance().then((value) {
            value.setString("notifications", json.encode(mapList));
          });
        }
      });
      widget.notifications = getNotifications();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15, top: 15),
            child: Text(
              "My Notifications",
              style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: FutureBuilder(
                future: widget.notifications,
                builder:
                    (context, AsyncSnapshot<List<Notifications>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          print(snapshot.data![index].read);
                          return Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 9, right: 9, top: 10, bottom: 10),
                              constraints: const BoxConstraints(
                                  minHeight: 52, minWidth: 322),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  border: Border.all(
                                      width: 2,
                                      color: const Color(0xFFC8D1E6))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 46,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: SvgPicture.asset(
                                        "assets/info-icon.svg",
                                        width: 32,
                                        height: 32,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      parseFragment(snapshot.data![index].title)
                                          .text!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.openSans(
                                          fontWeight: snapshot.data![index].read
                                              ? FontWeight.w400
                                              : FontWeight.w700,
                                          fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 10);
                        },
                        itemCount: snapshot.data!.length);
                  } else {
                    return const Text("An error happened.");
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 15),
            child: Text(
              "My Projects",
              style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Flexible(
              child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: FutureBuilder(
              future: widget.projects,
              builder: (context, AsyncSnapshot<List<Projects>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.hasData == false) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData && snapshot.data != null) {
                  snapshot.data!.removeWhere((element) =>
                      element.registrable == false &&
                      element.registered == false);
                  snapshot.data!.removeWhere(
                      (element) => element.endDate.isBefore(DateTime.now()));
                  snapshot.data!.sort((a, b) => a.endDate.compareTo(b.endDate));
                  return Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Container(
                      width: double.infinity,
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.only(
                                left: 9, right: 9, top: 10, bottom: 10),
                            constraints: const BoxConstraints(
                                minHeight: 52, minWidth: 322),
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                border: Border.all(
                                    width: 2, color: const Color(0xFFC8D1E6))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 46,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: SvgPicture.asset(
                                      "assets/project-icon.svg",
                                      width: 32,
                                      height: 32,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      snapshot.data![index].title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.openSans(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                                if (snapshot.data![index].registered)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "End:",
                                        textAlign: TextAlign.start,
                                        style: GoogleFonts.openSans(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12),
                                      ),
                                      Text(
                                        snapshot.data![index].endDate
                                                    .difference(DateTime.now())
                                                    .inDays >
                                                1
                                            ? "${snapshot.data![index].endDate.difference(DateTime.now()).inDays} days"
                                            : "${snapshot.data![index].endDate.difference(DateTime.now()).inDays} day",
                                        style: GoogleFonts.openSans(
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF7293E1),
                                            fontSize: 12),
                                      )
                                    ],
                                  ),
                                if (snapshot.data![index].registered == false &&
                                    snapshot.data![index].registrable)
                                  InkWell(
                                    child: Container(
                                      width: 90,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        border: Border.all(
                                            width: 2, color: Color(0xFFC8D1E6)),
                                        color: Color(0xFF7293E1),
                                      ),
                                      child: Center(
                                          child: Text(
                                        "Register",
                                        style: GoogleFonts.openSans(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: Colors.white),
                                      )),
                                    ),
                                    onTap: () async {
                                      bool result = await registerToProject(
                                          snapshot.data![index]);
                                      if (result) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "You have been registered !")),
                                        );
                                        setState(() {
                                          widget.projects = getProjectData();
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text("An error occured.")),
                                        );
                                      }
                                    },
                                  )
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 10);
                        },
                      ),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data == null) {
                  return const Text("");
                } else {
                  return const Text("Error. Please reload the app");
                }
              },
            ),
          )),
        ],
      ),
    );
  }
}

Future<bool> registerToProject(Projects project) async {
  final prefs = await SharedPreferences.getInstance();
  String? user = prefs.getString("user");
  print("url : " + project.registerUrl);
  if (user == null) {
    return false;
  }
  final url = project.registerUrl;
  final client = http.Client();
  final cookieValue = user;
  final request = http.Request('POST', Uri.parse(url));
  request.headers['cookie'] = "user=$cookieValue";
  final response = await client.send(request);
  if (response.statusCode != 200) {
    client.close();
    return false;
  }
  client.close();
  return true;
}
