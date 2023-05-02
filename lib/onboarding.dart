import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:my_intra/main.dart';

class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({Key? key}) : super(key: key);

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  AppUpdateInfo? _updateInfo;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });
    }).catchError((e) {
      showSnack(e.toString());
    });
  }

  @override
  void initState() {
    checkForUpdate();
    // TODO: implement initState
    super.initState();
  }

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable &&
        _updateInfo!.availableVersionCode!.isEven) {
      InAppUpdate.performImmediateUpdate()
          .catchError((e) => showSnack(e.toString()));
    } else if (_updateInfo?.updateAvailability ==
        UpdateAvailability.updateAvailable) {
      InAppUpdate.startFlexibleUpdate();
    }
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
                  Padding(
                    padding: const EdgeInsets.only(top: 11),
                    child: SvgPicture.asset(
                      "assets/logo.svg",
                      width: 105,
                      height: 146,
                    ),
                  ),
                  Text("{ My Intra }",
                      style: GoogleFonts.openSans(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
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

  Future<void> showUpdateMessage(BuildContext context) async {
    await Future.delayed(const Duration(microseconds: 1));
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Update'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                    'Because of a radical change to the login process of the Intranet, the old app was not working anymore'),
                Text(
                    'We decided to recode My Intra from scratch, and releasing the app to iOS.'),
                Text(
                    'The app will have new features and a way better design. We are planning on releasing it in the next few weeks.'),
                Text(
                    'In the meantime we have pushed this version of the app so that you will be notified when the new app will be released with a built-in update feature.')
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
