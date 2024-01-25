import 'package:flutter/material.dart';
import 'package:live_sensors/controller.dart';
import 'package:live_sensors/logger/view.dart';
import 'package:live_sensors/queue/view.dart';
import 'toggle_tracking_btn.dart';
import 'stats.dart';

class HomePage extends StatelessWidget {
  final AppController controller;
  const HomePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MylesVision'),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                controller.logout();
              },
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.info)),
              Tab(icon: Icon(Icons.dns)),
              Tab(icon: Icon(Icons.pending_actions)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LoggerView(),
            QueueView(queue: controller.queue),
            StatsView(controller: controller),
          ],
        ),
        floatingActionButton: ToggleTrackingBtn(controller: controller),
      ),
    );
  }
}
