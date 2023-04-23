import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_intra/main.dart';
import 'package:my_intra/model/profile.dart';
import 'package:my_intra/styleText.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.data}) : super(key: key);
  final Profile data;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: EdgeInsets.only(left: 35, right: 35, top: 32, bottom: 30),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              color: Color(0xFF7293E1),
              border: Border.all(
                color: Color(0xFF7293E1),
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
                          widget.data.firstname + " " + widget.data.name,
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
                        defaultStyle:
                            TextStyle(fontSize: 16, color: Colors.black),
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
                      StyledTextWidget(
                        text: "Promotion ${widget.data.promo}",
                        defaultStyle:
                            TextStyle(fontSize: 16, color: Colors.black),
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
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(right: 13, left: 13),
                        child: Text(
                          "${widget.data.studentyear == "1" ? "1st" : widget.data.studentyear == "2" ? "2nd" : "${widget.data.studentyear}rd"} Year",
                          style: GoogleFonts.openSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: Color(0xFF7293E1)),
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(22)),
                      child: Image.network(
                        'https://intra.epitech.eu/file/userprofil/profilview/${widget.data.email}.png',
                        headers: {'Cookie': 'user=${widget.data.cookie}'},
                        scale: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PieChart(
              dataMap: {
                "Active": double.parse(widget.data.activeLogTime),
                "Time Off": (70 - double.parse(widget.data.activeLogTime))
              },
              colorList: [Color(0xFF7293E1), Color(0xFFD4E1FF)],
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginIntra()),
                );
              },
              child: const Text("Se déconnecter"))
        ],
      ),
    );
  }
}
