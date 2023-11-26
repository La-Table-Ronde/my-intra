import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_intra/main.dart';
import 'package:my_intra/model/notifications.dart';
import 'package:my_intra/model/profile.dart';
import 'package:my_intra/model/projects.dart';
import 'package:my_intra/utils/files_modal.dart';
import 'package:my_intra/utils/get_files_project.dart';

import 'consts.dart' as consts;
import 'globals.dart' as globals;

class HomeWidget extends StatefulWidget {
  const HomeWidget(
      {Key? key,
      required this.data,
      required this.projects,
      this.notifications,
      required this.index})
      : super(key: key);
  final Future<List<Projects>>? projects;
  final Profile data;
  final Future<List<Notifications>>? notifications;
  final ValueNotifier<int> index;

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 15, bottom: 14),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: Border.all(color: Color(consts.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome,",
                      style: GoogleFonts.openSans(
                          fontWeight: FontWeight.w400, fontSize: 15),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      "${widget.data.firstname} ${widget.data.name}",
                      style: GoogleFonts.openSans(
                          fontWeight: FontWeight.w700, fontSize: 15),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                if (globals.adminMode == false)
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    child: Image.network(
                      'https://intra.epitech.eu/file/userprofil/profilview/${widget.data.email}.png',
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person,
                            color: Colors.black, size: 44);
                      },
                      width: 64,
                      height: 64,
                      headers: {'Cookie': 'user=${widget.data.cookie}'},
                      scale: 2,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 5),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 140),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xFF7293E1),
                  border: Border.all(color: const Color(0xFFC8D1E6), width: 3),
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: FutureBuilder(
                  future: widget.notifications,
                  builder:
                      (context, AsyncSnapshot<List<Notifications>> snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      int unread = snapshot.data!
                          .where((element) => element.read == false)
                          .length;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                "You have",
                                style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20,
                                    color: Colors.white),
                              ),
                              Text(
                                "$unread notifications",
                                style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          SvgPicture.asset(unread != 0
                              ? "assets/bob-awake.svg"
                              : "assets/bob-sleeping.svg")
                        ],
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginIntra()),
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            "An error occured.",
                            style: GoogleFonts.openSans(
                                fontWeight: FontWeight.w400,
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ],
                      );
                    }
                  }),
            ),
          ),
          InkWell(
            onTap: () async {
              widget.index.value = 2;
            },
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  border: Border.all(color: const Color(0xFFC8D1E6), width: 2)),
              child: Center(
                  child: Text(
                "Click here to see your notifications",
                style: GoogleFonts.openSans(
                    color: const Color(0xFF7293E1),
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Current projects",
                textAlign: TextAlign.start,
                style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: FutureBuilder(
                future: widget.projects,
                builder: (context, AsyncSnapshot<List<Projects>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.hasData == false && snapshot.error == false) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasData && snapshot.data != null) {
                    final newList = List.from(snapshot.data!);
                    newList
                        .removeWhere((element) => element.registered == false);
                    newList.removeWhere(
                        (element) => element.endDate.isBefore(DateTime.now()));
                    newList.sort((a, b) => a.endDate.compareTo(b.endDate));
                    return Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: SizedBox(
                        width: double.infinity,
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: newList.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () async {
                                await showFileModal(newList[index], context);
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 10, bottom: 10),
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
                                          "assets/project-icon.svg",
                                          width: 32,
                                          height: 32,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        newList[index].title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                        style: GoogleFonts.openSans(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "End:",
                                          textAlign: TextAlign.start,
                                          style: GoogleFonts.openSans(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12),
                                        ),
                                        Text(
                                          newList[index]
                                                      .endDate
                                                      .difference(
                                                          DateTime.now())
                                                      .inDays >
                                                  1
                                              ? "${newList[index].endDate.difference(DateTime.now()).inDays} days"
                                              : newList[index]
                                                          .endDate
                                                          .difference(
                                                              DateTime.now())
                                                          .inDays ==
                                                      0
                                                  ? "Today"
                                                  : "${newList[index].endDate.difference(DateTime.now()).inDays} day",
                                          style: GoogleFonts.openSans(
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF7293E1),
                                              fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
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
            ),
          ),
        ],
      ),
    );
  }
}
