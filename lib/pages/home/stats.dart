import 'dart:async';
import 'package:flutter/material.dart';
import 'package:live_sensors/controller.dart';

class StatsView extends StatefulWidget {
  final AppController controller;
  const StatsView({super.key, required this.controller});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> with TickerProviderStateMixin {
  String sensorsUpdates = 'Measuring...';
  String positionUpdates = 'Measuring...';
  String snapshotsCount = 'Measuring...';

  late AnimationController controller;
  late Function _unsubscribe;

  @override
  initState() {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: widget.controller.tracker.positionFreq.updateStatsFrequency,
    )..addListener(() {
        setState(() {});
      });
    controller.repeat();
    super.initState();
    Duration freq = widget.controller.tracker.positionFreq.updateStatsFrequency;
    Timer.periodic(freq, (timer) {
      if (mounted) {
        setState(() {
          positionUpdates =
              '${widget.controller.tracker.positionFreq.mean.toStringAsPrecision(2)} times / sec';
          sensorsUpdates =
              '${widget.controller.tracker.sensorsFreq.mean.toStringAsPrecision(2)} times / sec';
          snapshotsCount = '${widget.controller.sender.counter} pcs';
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
            LinearProgressIndicator(
              value: controller.value,
              semanticsLabel: 'Linear progress indicator',
            ),
            const SizedBox(height: 8),
            Text('Position updates: $positionUpdates'),
            Text('Sensors updates: $sensorsUpdates'),
            Text('Snapshots sended: $snapshotsCount'),
          ],
        ));
  }
}
