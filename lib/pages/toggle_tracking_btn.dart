import 'package:flutter/material.dart';
import 'package:live_sensors/main.dart';

class ToggleTrackingBtn extends StatefulWidget {
  final AppController controller;
  const ToggleTrackingBtn({super.key, required this.controller});

  @override
  State<ToggleTrackingBtn> createState() => _ToggleTrackingBtnState();
}

class _ToggleTrackingBtnState extends State<ToggleTrackingBtn> {
  bool isTracking = false;
  late Function _unsubscribe;

  @override
  initState() {
    super.initState();
    _unsubscribe = widget.controller.subscribe((newState) {
      setState(() {
        isTracking = newState.isTracking;
      });
    });
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  toggleTracking() {
    if (isTracking) {
      widget.controller.pauseTracking();
    } else {
      widget.controller.resumeTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: toggleTracking,
      tooltip: 'Show position',
      child:
          isTracking ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
    );
  }
}
