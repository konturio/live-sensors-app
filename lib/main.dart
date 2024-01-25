import 'package:flutter/material.dart';
import 'package:live_sensors/controller.dart';

import 'pages/home/home.dart';
import 'pages/login/login.dart';
import 'pages/spinner/spinner.dart';

void main() => runApp(LiveSensorsApp(controller: AppController()));

class LiveSensorsApp extends StatefulWidget {
  final AppController controller;
  const LiveSensorsApp({super.key, required this.controller});
  @override
  LiveSensorsAppState createState() => LiveSensorsAppState();
}

class LiveSensorsAppState extends State<LiveSensorsApp> {
  bool isLoggedIn = false;
  bool isReady = false;
  late Function _unsubscribe;

  @override
  void initState() {
    super.initState();
    _unsubscribe = widget.controller.subscribe((state) {
      setState(() {
        isLoggedIn = state.isAuthorized;
        isReady = state.isBooted;
      });
    });
    widget.controller.init();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'MylesVision',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: isReady
            ? isLoggedIn
                ? HomePage(controller: widget.controller)
                : LoginPage(controller: widget.controller)
            : const SpinnerPage());
  }
}
