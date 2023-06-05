import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:my_intra/home.dart';
import 'package:my_intra/main.dart';

import 'globals.dart' as globals;

class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({Key? key}) : super(key: key);

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  AppUpdateInfo? _updateInfo;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

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
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 92, right: 29, left: 29, bottom: 65),
            child: Column(
              mainAxisSize: MainAxisSize.max,
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
                Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginIntra()));
                      },
                      child: Container(
                        width: 332,
                        height: 40,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(53))),
                        child: Center(
                            child: Text(
                          "Sign In",
                          style: GoogleFonts.openSans(
                              fontSize: 16,
                              color: const Color(0xFF7293E1),
                              fontWeight: FontWeight.w700),
                        )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
                          onTap: () {
                            showLoginAdmin(context).then((value) {
                              if (value == true) {
                                globals.adminMode = true;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HomePageLoggedIn()),
                                );
                              }
                            });
                          },
                          child: Text(
                            "Admin Access",
                            style: GoogleFonts.openSans(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
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

  Future<bool> showLoginAdmin(BuildContext context) async {
    await Future.delayed(const Duration(microseconds: 1));
    final field = TextEditingController();
    bool res = false;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: field,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.login),
                      hintText: 'Login value',
                      labelText: 'Login',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  if (field.text == "CorentinTuCassesLesCouilles") {
                    res = true;
                  } else {
                    res = false;
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return res;
  }
}
