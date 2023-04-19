import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetGpa extends StatefulWidget {
  const GetGpa({super.key});

  @override
  State<GetGpa> createState() => _GetGpaState();
}

class _GetGpaState extends State<GetGpa> {
  String gpa = "Unknown";
  String response = "";
  Future<dynamic> makeHttpRequestWithCookie() async {
    final prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString("user");

    // Define the URL and endpoint of the API you want to call
    const url = 'https://intra.epitech.eu/user/?format=json';

    // Create a new http.Client instance
    final client = http.Client();

    // Define your cookie value
    final cookieValue = user;

    // Create a new http.Request object with the desired URL
    final request = http.Request('GET', Uri.parse(url));
    print(cookieValue);
    // Set the cookie header in the request
    request.headers['cookie'] = "user=${cookieValue!}";

    // Send the request and wait for the response
    final response = await client.send(request);

    // Read the response body as a list of bytes
    final responseBytes = await response.stream.toList();

    // Convert the list of bytes to a string
    final responseString =
        utf8.decode(responseBytes.expand((byte) => byte).toList());

    // Process the response as needed
    print('Response: $responseString');
    final responseJson = jsonDecode(responseString);

// Extract the "gpa" value from the response

    client.close();
    return responseJson;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Flutter WebView example'),
          // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        ),
        body: Column(
          children: [
            Text(gpa),
            ElevatedButton(
                onPressed: () {
                  makeHttpRequestWithCookie().then((value) {
                    setState(() {
                      gpa = value['gpa'][0]['gpa'];
                      response = value.toString();
                    });
                  });
                },
                child: const Text("Get GPA")),
            Text(response),
          ],
        ));
  }
}
