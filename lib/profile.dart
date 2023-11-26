import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_intra/model/profile.dart';
import 'package:my_intra/styleText.dart';
import 'package:pie_chart/pie_chart.dart';

import 'globals.dart' as globals;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.data, required this.scaffoldKey})
      : super(key: key);
  final Profile data;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 0, top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "My profile",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        showSnack("Coming soon...");
                      },
                      icon: const Icon(Icons.settings))
                ],
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 30, bottom: 30),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: const Color(0xFF7293E1),
                  border: Border.all(
                    color: const Color(0xFF7293E1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Text(
                              "${widget.data.firstname} ${widget.data.name}",
                              style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24,
                                  color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StyledTextWidget(
                            text: "City: ${widget.data.city}",
                            defaultStyle: const TextStyle(
                                fontSize: 16, color: Colors.black),
                            wordStyles: [
                              GoogleFonts.openSans(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.white),
                              GoogleFonts.openSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Colors.white)
                            ],
                          ),
                          const SizedBox(height: 1),
                          StyledTextWidget(
                            text: "Promotion ${widget.data.promo}",
                            defaultStyle: const TextStyle(
                                fontSize: 16, color: Colors.black),
                            wordStyles: [
                              GoogleFonts.openSans(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.white),
                              GoogleFonts.openSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Colors.white)
                            ],
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.only(right: 13, left: 13),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                color: Colors.white),
                            child: Text(
                              "${widget.data.studentyear == "1" ? "1st" : widget.data.studentyear == "2" ? "2nd" : "${widget.data.studentyear}rd"} Year",
                              style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  color: const Color(0xFF7293E1)),
                            ),
                          )
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (globals.adminMode == false)
                          Center(
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(22)),
                              child: Image.network(
                                'https://intra.epitech.eu/file/userprofil/profilview/${widget.data.email}.png',
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.person,
                                      color: Colors.white, size: 44);
                                },
                                width: 96,
                                height: 96,
                                headers: {
                                  'Cookie': 'user=${widget.data.cookie}'
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  constraints:
                      const BoxConstraints(maxWidth: 361, maxHeight: 130),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border:
                          Border.all(color: const Color(0xFFC8D1E6), width: 2)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Total credits acquired :",
                              style: GoogleFonts.lato(
                                  fontWeight: FontWeight.w400, fontSize: 12),
                            ),
                            Text(
                              widget.data.fullCredits,
                              style: GoogleFonts.lato(
                                  color: const Color(0xFF7293E1),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  "Current semester :",
                                  style: GoogleFonts.lato(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12),
                                )),
                            Text(
                              widget.data.semester,
                              style: GoogleFonts.lato(
                                  color: const Color(0xFF7293E1),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 50),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "GPA :",
                              style: GoogleFonts.lato(
                                  fontWeight: FontWeight.w400, fontSize: 12),
                            ),
                            Text(
                              widget.data.gpa,
                              style: GoogleFonts.lato(
                                  color: const Color(0xFF7293E1),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  "Log time :",
                                  style: GoogleFonts.lato(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12),
                                )),
                            Text(
                              widget.data.activeLogTime,
                              style: GoogleFonts.lato(
                                  color: const Color(0xFF7293E1),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Text(
              "My Log Time",
              style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w600, fontSize: 16),
            ),
            Center(
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 250, maxHeight: 250),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PieChart(
                    initialAngleInDegree: 90,
                    dataMap: {
                      "Active": double.parse(widget.data.activeLogTime),
                      "Time Off": (70 - double.parse(widget.data.activeLogTime))
                    },
                    legendOptions: const LegendOptions(
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.right,
                      showLegends: false,
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: false,
                      decimalPlaces: 1,
                    ),
                    colorList: const [Color(0xFF7293E1), Color(0xFFD4E1FF)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
