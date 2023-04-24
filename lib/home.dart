import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:my_intra/home_widget.dart';
import 'package:my_intra/model/profile.dart';
import 'package:my_intra/onboarding.dart';
import 'package:my_intra/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: null,
        body: FutureBuilder(
          future: checkUserLoggedIn(),
          builder: (context, AsyncSnapshot<bool> res) {
            if (res.hasData == false) {
              return const CircularProgressIndicator();
            }
            if (res.hasError == true || res.hasData && res.data == false) {
              return const OnboardingWidget();
              return const Text("Une erreur s'est produite");
            } else {
              return const HomePageLoggedIn();
            }
          },
        ),
      ),
    );
  }
}

class HomePageLoggedIn extends StatefulWidget {
  const HomePageLoggedIn({Key? key}) : super(key: key);

  @override
  State<HomePageLoggedIn> createState() => _HomePageLoggedInState();
}

class _HomePageLoggedInState extends State<HomePageLoggedIn> {
  Widget? displayedWidget;
  int _selectedIndex = 0;
  bool firstRun = true;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getProfileData(),
      builder: (context, AsyncSnapshot<Profile> res) {
        if (res.hasError) {
          return Text("Une erreur s'est produite hmm ${res.error}");
        }
        if (res.hasData && res.data != null) {
          firstRun ? displayedWidget = HomeWidget(data: res.data!) : 0;
          return SafeArea(
            child: Scaffold(
                bottomNavigationBar: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 19, right: 14, left: 14),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFFC8D1E6), width: 3),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: BottomNavigationBar(
                        type: BottomNavigationBarType.fixed,
                        showSelectedLabels: false,
                        showUnselectedLabels: false,
                        selectedIconTheme:
                            const IconThemeData(color: Color(0xFF7293E1)),
                        items: [
                          BottomNavigationBarItem(
                              icon: SvgPicture.asset(
                                _selectedIndex == 0
                                    ? "assets/home-icon-selected.svg"
                                    : "assets/home-icon.svg",
                              ),
                              label: "Home"),
                          BottomNavigationBarItem(
                              icon: SvgPicture.asset(
                                _selectedIndex == 1
                                    ? "assets/calendar-icon-selected.svg"
                                    : "assets/calendar-icon.svg",
                              ),
                              label: "Agenda"),
                          BottomNavigationBarItem(
                              icon: SvgPicture.asset(
                                _selectedIndex == 2
                                    ? "assets/notif-icon-selected.svg"
                                    : "assets/notif-icon.svg",
                              ),
                              label: "Alertes"),
                          BottomNavigationBarItem(
                              icon: SvgPicture.asset(
                                _selectedIndex == 3
                                    ? "assets/profile-icon-selected.svg"
                                    : "assets/profile-icon.svg",
                              ),
                              label: "profil")
                        ],
                        currentIndex: _selectedIndex,
                        onTap: (index) {
                          setState(() {
                            firstRun = false;
                            _selectedIndex = index;
                            displayedWidget = null;
                            if (index == 3) {
                              displayedWidget = ProfilePage(data: res.data!);
                            }
                            if (index == 0) {
                              displayedWidget = HomeWidget(data: res.data!);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
                body: displayedWidget),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

Future<bool> checkUserLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  String? user = prefs.getString("user");
  if (user == null) {
    return false;
  }
  const url = 'https://intra.epitech.eu/user/?format=json';
  final client = http.Client();
  final cookieValue = user;
  final request = http.Request('GET', Uri.parse(url));
  request.headers['cookie'] = "user=$cookieValue";
  final response = await client.send(request);
  if (response.statusCode != 200) {
    client.close();
    return false;
  }
  client.close();
  return true;
}

Future<void> showDialogConnexionIntra(BuildContext context) async {
  await Future.delayed(const Duration(microseconds: 1));
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Connexion'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text(
                  'Since the end of 2022, it is not longer possible to login with an autologin link.'),
              Text(
                  'Therefore, My Intra uses a cookie system to keep you logged in.'),
              Text(
                  'For this to work, you need to login to your Intra account, then the application will automatically retrieve the cookie.')
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

Future<Profile> getProfileData() async {
  final prefs = await SharedPreferences.getInstance();
  String? user = prefs.getString("user");
  const url = 'https://intra.epitech.eu/user/?format=json';
  final client = http.Client();
  final cookieValue = user;
  final request = http.Request('GET', Uri.parse(url));
  request.headers['cookie'] = "user=$cookieValue";
  final response = await client.send(request);
  if (response.statusCode != 200) {
    return Future.error("Error${response.statusCode}");
  }
  final responseBytes = await response.stream.toList();
  final responseString =
      utf8.decode(responseBytes.expand((byte) => byte).toList());
  final value = jsonDecode(responseString);

  return Profile(
      gpa: value['gpa'][0]['gpa'],
      name: value['lastname'].toString(),
      firstname: value['firstname'].toString(),
      semester: value['semester'].toString(),
      city: value['userinfo']['city']['value'].toString(),
      activeLogTime: value['nsstat']['active'].toString(),
      idleLogTime: value['nsstat']['idle'].toString(),
      fullCredits: value['credits'].toString(),
      email: value['internal_email'].toString(),
      cookie: cookieValue!,
      promo: value['promo'].toString(),
      studentyear: value['studentyear'].toString());
}
