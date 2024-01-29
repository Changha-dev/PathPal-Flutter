import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:pathpal/screens/vt/car_main.dart';
import 'package:pathpal/screens/vt/progress_2.dart';
import 'package:pathpal/theme.dart';
import 'package:pathpal/utils/app_images.dart';
import 'package:pathpal/widgets/build_image.dart';
import 'package:pathpal/widgets/cancel_button.dart';
import 'package:pathpal/widgets/dp_info.dart';
import 'package:pathpal/widgets/next_button.dart';
import 'package:pathpal/widgets/progress_app_bar.dart';
import 'package:pathpal/widgets/stepper.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../widgets/custom_dialog.dart';

class VtProgress extends StatefulWidget {
  String? arriveTime = "";
  String carId;

  VtProgress({this.arriveTime, required this.carId});

  @override
  State<VtProgress> createState() => _VtProgressState();
}

class _VtProgressState extends State<VtProgress> {
  @override
  Widget build(BuildContext context) {
    final stepper = CustomStepper(
      steps: ['가는중', '탑승 완료'],
      currentStep: 0,
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
              Expanded(
                  child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  CancelButton(
                      title: "봉사 취소하기",
                      onPressed: () {
                        print('봉사 취소하기');
                      }),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: double.infinity,
                    height: 40,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(30.0, 8.0, 0, 0),
                      child: Text(
                        '${widget.arriveTime}',
                        style: appTextTheme().bodyLarge,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: gray200,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                  DpInfo(
                    backgroundColor: Colors.white,
                  ),
                ],
              )),
              NextButton(
                title: "탑승 완료",
                onPressed: () async {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return RectangleDialog(
                        title: '탑승 완료',
                        message: '정말로 탑승 완료 버튼을 누르시겠습니까?',
                        okLabel: '확인',
                        cancelLabel: '취소',
                        okPressed: () {
                          FirebaseFirestore.instance
                              .collection('cars')
                              .doc(widget.carId)
                              .update({'status': 'boarding'}).then((_) {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
