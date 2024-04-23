import 'package:flutter/material.dart';

import '../../widgets/progress_app_bar.dart';
import '../../widgets/stepper.dart';

class VtProgress2 extends StatefulWidget {
  const VtProgress2({super.key});

  @override
  State<VtProgress2> createState() => _VtProgress2State();
}

class _VtProgress2State extends State<VtProgress2> {
  @override
  Widget build(BuildContext context) {
    final stepper = CustomStepper(
      //가는중 탑승완료 이동중 도착완료 이렇게 Steps만드려고함

      steps: ['가는중', '탑승 완료', '이동중', '도착완료'],
      currentStep: 1,
    );
    return Scaffold(
      appBar: ProgressAppBar(),
      body: Builder(
        builder: (BuildContext context) {
          final double appBarHeight = Scaffold.of(context).appBarMaxHeight ?? 0;
          final double screenHeight = MediaQuery.of(context).size.height;
          final double stepperHeight = (screenHeight - appBarHeight) * 0.2;

          return Column(
            children: [
              Container(height: stepperHeight, child: stepper),
            ],
          );
        },
      ),
    );
  }
}
