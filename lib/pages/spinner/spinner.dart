import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SpinnerPage extends StatelessWidget {
  const SpinnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
          body: Center(
        child: SpinKitPulsingGrid(
          color: Colors.green,
          size: 50.0,
        ),
      )),
    );
  }
}
