import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_intra/main.dart';
import 'package:my_intra/model/profile.dart';
import 'package:my_intra/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
              return CircularProgressIndicator();
            }
            if (res.hasError == true || res.hasData && res.data == false) {
              _showDialogConnexionIntra(context).then((value) => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginIntra()),
                  ));
              return Text("Une erreur s'est produite");
            } else {
              return HomePageLoggedIn();
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getProfileData(),
      builder: (context, AsyncSnapshot<Profile> res) {
        if (res.hasError) {
          return Text("Une erreur s'est produite hmm ${res.error}");
        }
        if (res.hasData && res.data != null) {
          return Scaffold(
              bottomNavigationBar: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(
                        Icons.home,
                        color: Colors.grey,
                      ),
                      label: "Home"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_month, color: Colors.grey),
                      label: "Agenda"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.notification_add, color: Colors.grey),
                      label: "Alertes"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person, color: Colors.grey),
                      label: "Profil"),
                ],
                selectedItemColor: Colors.grey,
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                    if (index == 3)
                      displayedWidget = ProfilePage(data: res.data!);
                  });
                },
              ),
              body: displayedWidget);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

Future<bool> checkUserLoggedIn() async {
  final _prefs = await SharedPreferences.getInstance();
  String? _user = _prefs.getString("user");
  if (_user == null) {
    return false;
  }
  final url = 'https://intra.epitech.eu/user/?format=json';
  final client = http.Client();
  final cookieValue = _user;
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

Future<void> _showDialogConnexionIntra(BuildContext context) async {
  await Future.delayed(Duration(microseconds: 1));
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
                  'Depuis fin 2022, il n\'est plus possible de se connecter à Epitech Intra via l\'autologin.'),
              Text(
                  'Ainsi, My Intra a été mise à jour pour vous permettre de vous connecter à votre compte Epitech, grâce à un system de cookie.'),
              Text(
                  'Pour cela veuillez vous connecter à l\'intra avec votre compte Epitech, puis cliquer sur le bouton "je suis connecté".')
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Se connecter'),
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
  final _prefs = await SharedPreferences.getInstance();
  String? _user = _prefs.getString("user");
  final url = 'https://intra.epitech.eu/user/?format=json';
  final client = http.Client();
  final cookieValue = _user;
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
      cookie: cookieValue!);
}
