import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_intra/main.dart';

class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({Key? key}) : super(key: key);

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7293E1),
      body: Padding(
        padding:
            const EdgeInsets.only(top: 92, right: 29, left: 29, bottom: 65),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Column(
                children: [
                  Text("My_Intra",
                      style: GoogleFonts.openSans(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Padding(
                    padding: const EdgeInsets.only(top: 11),
                    child: SvgPicture.asset(
                      "assets/logo.svg",
                      width: 74,
                      height: 79,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "A mobile app for Epitech students",
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginIntra()),
                );
              },
              child: Container(
                width: 332,
                height: 40,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(53))),
                child: Center(
                    child: Text(
                  "Sign In",
                  style: GoogleFonts.openSans(
                      fontSize: 16,
                      color: const Color(0xFF7293E1),
                      fontWeight: FontWeight.w700),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
