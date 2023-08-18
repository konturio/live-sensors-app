import 'dart:async';
import 'package:flutter/material.dart';
import 'package:live_sensors/controller.dart';

class StatsView extends StatefulWidget {
  final AppController controller;
  const StatsView({super.key, required this.controller});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  String sensorsUpdates = 'Measuring...';
  String positionUpdates = 'Measuring...';

  late Function _unsubscribe;

  @override
  initState() {
    super.initState();
    Duration freq = widget.controller.tracker.positionFreq.updateStatsFrequency;
    Timer.periodic(freq, (timer) {
      if (mounted) {
        setState(() {
          positionUpdates =
              '${widget.controller.tracker.positionFreq.mean.toStringAsPrecision(2)} times / sec';
          sensorsUpdates =
              '${widget.controller.tracker.sensorsFreq.mean.toStringAsPrecision(2)} times / sec';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Position updates: $positionUpdates'),
            Text('Sensors updates: $sensorsUpdates'),
          ],
        ));
  }
}
