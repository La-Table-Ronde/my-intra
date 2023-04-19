import 'package:flutter/material.dart';
import 'package:my_intra/main.dart';
import 'package:my_intra/model/profile.dart';
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                color: Colors.blue,
                border: Border.all(
                  color: Colors.blue,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Image.network(
                        'https://intra.epitech.eu/file/userprofil/profilview/${widget.data.email}.png',
                        headers: {'Cookie': 'user=${widget.data.cookie}'},
                        scale: 2,
                      ),
                      const Text("Total credits acquired :"),
                      Text(widget.data.fullCredits),
                      const Text("Name : "),
                      Text("${widget.data.name} ${widget.data.firstname}")
                    ],
                  ),
                  Column(
                    children: [
                      const Text("GPA"),
                      Text(widget.data.gpa),
                      const Text("Log time :"),
                      Text(widget.data.activeLogTime),
                    ],
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PieChart(dataMap: {
              "Active": double.parse(widget.data.activeLogTime),
              "Idle": double.parse(widget.data.idleLogTime)
            }),
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
