import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:my_intra/calendar_widget.dart';
import 'package:my_intra/home_widget.dart';
import 'package:my_intra/model/notifications.dart';
import 'package:my_intra/model/profile.dart';
import 'package:my_intra/model/projects.dart';
import 'package:my_intra/notifications_widget.dart';
import 'package:my_intra/onboarding.dart';
import 'package:my_intra/profile.dart';
import 'package:my_intra/utils/fetch_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'globals.dart' as globals;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: null,
        body: FutureBuilder(
          future: checkUserLoggedIn(),
          builder: (context, AsyncSnapshot<bool> res) {
            if (res.hasData == false) {
              return const Center(child: CircularProgressIndicator());
            }
            if (res.hasError == true || res.hasData && res.data == false) {
              return const OnboardingWidget();
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
  const HomePageLoggedIn({super.key});

  @override
  State<HomePageLoggedIn> createState() => _HomePageLoggedInState();
}

class _HomePageLoggedInState extends State<HomePageLoggedIn> {
  Widget? displayedWidget;
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  bool firstRun = true;
  Future<List<Projects>>? projects;
  Future<List<Notifications>>? notifications;
  AppUpdateInfo? _updateInfo;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

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
    if (Platform.isAndroid) {
      checkForUpdate();
    }
    projects = getProjectData();
    notifications = getNotifications(true);
    globals.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    if (Platform.isAndroid) {
      Workmanager().registerPeriodicTask(
          "check-notifications", "check-notifications-task",
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingWorkPolicy.replace);
      Workmanager().registerPeriodicTask("check-events", "check-events-task",
          constraints: Constraints(networkType: NetworkType.connected),
          frequency: const Duration(minutes: 15),
          existingWorkPolicy: ExistingWorkPolicy.replace);
    } else if (Platform.isIOS) {
      Workmanager().registerOneOffTask(
          "check-notifications", "check-nootifications-task");
      Workmanager().registerOneOffTask("check-events", "check-events-task");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      if (_updateInfo?.updateAvailability ==
              UpdateAvailability.updateAvailable &&
          _updateInfo!.availableVersionCode!.isEven) {
        InAppUpdate.performImmediateUpdate().onError((e, stack) {
          showSnack(e.toString());
          return Future.error(stack);
        });
      } else if (_updateInfo?.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        InAppUpdate.startFlexibleUpdate();
      }
    }
    return FutureBuilder(
      future: getProfileData(),
      builder: (context, AsyncSnapshot<Profile> res) {
        if (res.hasError) {
          return Text("Une erreur s'est produite ${res.error}");
        }
        if (res.hasData && res.data != null) {
          firstRun
              ? displayedWidget = HomeWidget(
                  data: res.data!,
                  projects: projects,
                  notifications: notifications,
                  index: _selectedIndex,
                )
              : 0;
          return ValueListenableBuilder<int>(
              valueListenable: _selectedIndex,
              builder: (context, value, child) {
                if (_selectedIndex.value == 2) {
                  displayedWidget = NotificationsWidget(
                    notifications: notifications,
                    data: res.data!,
                    projects: projects,
                  );
                  firstRun = false;
                }
                return Scaffold(
                    bottomNavigationBar: BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      showSelectedLabels: false,
                      showUnselectedLabels: false,
                      selectedIconTheme:
                          const IconThemeData(color: Color(0xFF7293E1)),
                      items: [
                        BottomNavigationBarItem(
                            icon: SvgPicture.asset(
                              _selectedIndex.value == 0
                                  ? "assets/home-icon-selected.svg"
                                  : "assets/home-icon.svg",
                            ),
                            label: "Home"),
                        BottomNavigationBarItem(
                            icon: SvgPicture.asset(
                              _selectedIndex.value == 1
                                  ? "assets/calendar-icon-selected.svg"
                                  : "assets/calendar-icon.svg",
                            ),
                            label: "Agenda"),
                        BottomNavigationBarItem(
                            icon: SvgPicture.asset(
                              _selectedIndex.value == 2
                                  ? "assets/notif-icon-selected.svg"
                                  : "assets/notif-icon.svg",
                            ),
                            label: "Alertes"),
                        BottomNavigationBarItem(
                            icon: SvgPicture.asset(
                              _selectedIndex.value == 3
                                  ? "assets/profile-icon-selected.svg"
                                  : "assets/profile-icon.svg",
                            ),
                            label: "profil")
                      ],
                      currentIndex: _selectedIndex.value,
                      onTap: (index) {
                        if (Platform.isAndroid) {
                          globals.flutterLocalNotificationsPlugin
                              .resolvePlatformSpecificImplementation<
                                  AndroidFlutterLocalNotificationsPlugin>()!
                              .requestNotificationsPermission();
                        }
                        setState(() {
                          firstRun = false;
                          _selectedIndex.value = index;
                          displayedWidget = null;
                          if (index == 1) {
                            displayedWidget = const CalendarWidget();
                          }
                          if (index == 3) {
                            displayedWidget = ProfilePage(
                                data: res.data!, scaffoldKey: _scaffoldKey);
                          }
                          if (index == 0) {
                            displayedWidget = HomeWidget(
                              data: res.data!,
                              projects: projects,
                              notifications: notifications,
                              index: _selectedIndex,
                            );
                          }
                          if (index == 2) {
                            displayedWidget = NotificationsWidget(
                              notifications: notifications,
                              data: res.data!,
                              projects: projects,
                            );
                          }
                        });
                      },
                    ),
                    body: SafeArea(child: displayedWidget!));
              });
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

Future<bool> checkUserLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  String? cookies = prefs.getString("cookies");
  if (cookies == null) {
    return false;
  }
  Map<String, String> cookieMap = {};
  jsonDecode(cookies).forEach((key, value) {
    cookieMap[key] = value;
  });

  const url = 'https://intra.epitech.eu/user/?format=json';
  HttpClient client = HttpClient();
  HttpClientRequest clientRequest = await client.getUrl(Uri.parse(url));
  clientRequest.cookies.addAll(cookieMap.entries
      .map((e) => Cookie(e.key, e.value))
      .toList(growable: false));
  final metric =
      FirebasePerformance.instance.newHttpMetric(url, HttpMethod.Get);
  await metric.start();
  HttpClientResponse response = await clientRequest.close();
  await metric.stop();

  if (response.statusCode != 200) {
    return false;
  }
  if (response.statusCode != 200) {
    client.close();
    return false;
  }
  client.close();
  return true;
}

Future<void> showDialogConnexionIntra(BuildContext context) async {
  await Future.delayed(const Duration(microseconds: 1));
  if (context.mounted) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connexion'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
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
}

Future<Profile> getProfileData() async {
  if (globals.adminMode) {
    return Profile(
        gpa: "4.0",
        name: "Elaoumari",
        firstname: "Adam",
        semester: "B4",
        city: "Marseille",
        activeLogTime: "10",
        idleLogTime: "15",
        fullCredits: "150",
        email: "adam.elaoumari@epitech.eu",
        promo: "MAR",
        studentyear: "2");
  }
  final prefs = await SharedPreferences.getInstance();
  String? cookies = prefs.getString("cookies");
  if (cookies == null) {
    return Future.error("No cookies");
  }
  Map<String, String> cookieMap = {};
  jsonDecode(cookies).forEach((key, value) {
    cookieMap[key] = value;
  });

  const url = 'https://intra.epitech.eu/user/?format=json';
  final stringData = await fetchData(url);
  final value = jsonDecode(stringData);
  Profile myProfile = Profile(
      gpa: value['gpa'][0]['gpa'] == null
          ? "0"
          : value['gpa'][0]['gpa'].toString(),
      name: value['lastname'].toString(),
      firstname: value['firstname'].toString(),
      semester: value['semester'] != null ? value['semester'].toString() : "0",
      city: value['groups'][0]['title'].toString(),
      activeLogTime:
          value['nsstat'] != null ? value['nsstat']['active'].toString() : "0",
      idleLogTime:
          value['nsstat'] != null ? value['nsstat']['idle'].toString() : "0",
      fullCredits: value['credits'] != null ? value['credits'].toString() : "0",
      email: value['internal_email'].toString(),
      promo: value['promo'] != null ? value['promo'].toString() : "0",
      studentyear:
          value['studentyear'] != null ? value['studentyear'].toString() : "0");
  await prefs.setString("email", myProfile.email);
  return myProfile;
}

Future<List<Projects>> getProjectData() async {
  if (globals.adminMode) {
    List<Projects> list = [];
    list.add(Projects(
        title: "Travailler",
        endDate: DateTime.now().add(const Duration(days: 12)),
        module: "Test",
        registered: true,
        registrable: false,
        registerUrl: "gmail.com",
        filesUrl: "gmail.com"));
    return list;
  }
  final prefs = await SharedPreferences.getInstance();
  String? cookies = prefs.getString("cookies");
  if (cookies == null) {
    return Future.error("No cookies");
  }
  Map<String, String> cookieMap = {};
  jsonDecode(cookies).forEach((key, value) {
    cookieMap[key] = value;
  });

  const url = 'https://intra.epitech.eu/?format=json';
  final stringData = await fetchData(url);
  final value = jsonDecode(stringData);
  List<dynamic> projects = value['board']['projets'];
  List<Projects> list = [];
  for (var project in projects) {
    String titleLink = project['title_link'];
    String projectLink = "";
    String titleLinkSave = project['title_link'];
    titleLinkSave = titleLinkSave.replaceAll(r'\/', '/');
    titleLinkSave = titleLinkSave.replaceAll('\\', '');
    titleLinkSave =
        "https://intra.epitech.eu${titleLinkSave}project/register?format=json";
    titleLink = titleLink.replaceAll(r'\/', '/');
    titleLink = titleLink.replaceAll('\\', '');
    projectLink = titleLink;
    titleLink = 'https://intra.epitech.eu${titleLink}project/?format=json';
    final responseString = await fetchData(titleLink);
    final value = jsonDecode(responseString);
    DateTime startProject = DateTime.parse(value['begin']);
    bool registrable =
        !value['closed'] && startProject.isBefore(DateTime.now());
    list.add(Projects(
        title: value['title'].toString(),
        registrable: registrable,
        endDate: DateTime.parse(value['end']),
        module: value['module_title'].toString(),
        registered: value['user_project_status'] != null ? true : false,
        registerUrl: titleLinkSave,
        filesUrl:
            'https://intra.epitech.eu${projectLink}project/file/?format=json'));
  }
  return list;
}

Future<List<Notifications>> getNotifications(bool? foreground) async {
  bool isForeground = false;
  foreground != null ? isForeground = foreground : 0;
  if (globals.adminMode) {
    List<Notifications> list = [];
    list.add(Notifications(
        id: "0",
        title: "Florian et Martin les goats",
        date: DateTime.now(),
        read: true,
        notifSent: true));
    return list;
  }
  final prefs = await SharedPreferences.getInstance();
  final responseString =
      await fetchData('https://intra.epitech.eu/?format=json');
  final value = jsonDecode(responseString);
  List<dynamic> notifs = value['history'];
  List<Notifications> list = [];
  String? data = prefs.getString("notifications");
  if (data != null) {
    final jsonList = json.decode(data) as List<dynamic>;
    list = jsonList.map((jsonObj) => Notifications.fromJson(jsonObj)).toList();
  }
  for (var notification in notifs) {
    final newNotif = Notifications(
        id: notification['id'],
        title: notification['title'],
        read: false,
        date: DateTime.parse(notification['date']),
        notifSent: isForeground ? true : false);
    bool alreadyExists = false;
    for (var obj in list) {
      if (obj.id == newNotif.id) {
        if (obj.date != newNotif.date) {
          list[list.indexOf(obj)] = newNotif;
        }
        alreadyExists = true;
        break;
      } else {
        if (obj.date == newNotif.date && obj.title == newNotif.title) {
          alreadyExists = true;
          break;
        }
      }
    }
    if (!alreadyExists) {
      list.add(newNotif);
    }
  }
  List<Map<String, dynamic>> mapList = [];
  for (Notifications obj in list) {
    mapList.add(obj.toJson());
  }
  final jsonValue = json.encode(mapList);
  log(jsonValue.toString());
  await prefs.setString("notifications", jsonValue);
  list.sort((a, b) => b.date.compareTo(a.date));
  return list;
}
