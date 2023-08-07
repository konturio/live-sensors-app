import 'package:flutter/material.dart';
import 'package:live_sensors/main.dart';
import 'package:live_sensors/logger/view.dart';
import 'package:live_sensors/queue/view.dart';
import 'toggle_tracking_btn.dart';

class HomePage extends StatelessWidget {
  final AppController controller;
  const HomePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live sensors',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Live sensors'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.info)),
                Tab(icon: Icon(Icons.dns)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              LoggerView(),
              QueueView(queue: controller.queue),
            ],
          ),
          floatingActionButton: ToggleTrackingBtn(controller: controller),
        ),
      ),
    );
  }
}
