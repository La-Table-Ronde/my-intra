import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_intra/model/profile.dart';

import 'consts.dart' as consts;

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key, required this.data}) : super(key: key);
  final Profile data;

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 50, bottom: 14),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
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
                          fontWeight: FontWeight.w700, fontSize: 15),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      "${widget.data.firstname} ${widget.data.name}",
                      style: GoogleFonts.openSans(
                          fontWeight: FontWeight.w400, fontSize: 15),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  child: Image.network(
                    'https://intra.epitech.eu/file/userprofil/profilview/${widget.data.email}.png',
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
              padding: const EdgeInsets.all(20),
              width: 361,
              height: 140,
              decoration: BoxDecoration(
                  color: const Color(0xFF7293E1),
                  border: Border.all(color: const Color(0xFFC8D1E6), width: 3),
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "You have",
                    style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                  Text(
                    "10 notifications",
                    style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 361,
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
          )
        ],
      ),
    );
  }
}
