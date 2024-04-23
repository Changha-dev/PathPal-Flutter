import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:pathpal/screens/vt/car_main.dart';
import 'package:pathpal/theme.dart';
import 'package:pathpal/utils/app_images.dart';
import 'package:pathpal/widgets/build_image.dart';
import 'package:pathpal/widgets/cancel_button.dart';
import 'package:pathpal/widgets/dp_info.dart';
import 'package:pathpal/widgets/next_button.dart';
import 'package:pathpal/widgets/progress_app_bar.dart';
import 'package:pathpal/widgets/stepper.dart';

import '../../colors.dart';
import '../../widgets/custom_dialog.dart';

class VtProgress extends StatefulWidget {
  String? arriveTime = "";
  String? carId;
  String? walkId;
  bool isWalkService;
  final String currentStatus;

  VtProgress({
    this.arriveTime,
    this.carId,
    this.walkId,
    required this.isWalkService,
    required this.currentStatus, // 생성자에 추가
  });

  @override
  State<VtProgress> createState() => _VtProgressState();
}

class _VtProgressState extends State<VtProgress> {
  int currentStep = 0; // 현재 단계를 추적하는 변수
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    // widget.currentStatus 값에 따라 currentStep을 업데이트
    switch (widget.currentStatus) {
      case 'going':
        currentStep = 0;
        break;
      case 'boarding':
        currentStep = 1;
        break;
      case 'moving':
        currentStep = 2;
        break;
      case 'arriving':
        currentStep = 3;
        break;
      default:
        currentStep = 0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    // 타이머를 시작하는 함수
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = _elapsedTime + Duration(seconds: 1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String buttonTitle;
    String nextStatus = currentStep == 2 ? 'arriving' : 'moving';

    if (currentStep < 3) {
      buttonTitle = widget.isWalkService
          ? ["미팅 완료", "이동중", "도착완료"][currentStep]
          : ["탑승 완료", "이동중", "도착완료"][currentStep];
    } else {
      // 최종 단계에서는 다른 액션을 정의하거나 버튼을 숨길 수 있음
      buttonTitle = "도착 완료"; // 예시
      // 도착 완료 버튼 로직 추가
    }

    final stepper = CustomStepper(
      steps: widget.isWalkService
          ? ['가는중', '미팅 완료', '이동중', '도착완료']
          : ['가는중', '탑승 완료', '이동중', '도착완료'],
      currentStep: currentStep,
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
                  buildButton(
                    title: "봉사 취소하기",
                    dialogTitle: '봉사 취소',
                    dialogMessage: '정말로 봉사를 취소하시겠습니까?',
                    status: 'waiting',
                  ),
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
                  if (currentStep == 2)
                    Text(
                        "봉사 시간: ${_elapsedTime.inMinutes}분 ${_elapsedTime.inSeconds % 60}초"),
                ],
              )),
              buildButton(
                title: "${buttonTitle}",
                dialogTitle: '${buttonTitle}',
                dialogMessage: '정말로 ${buttonTitle} 버튼을 누르시겠습니까?',
                status: nextStatus,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildButton(
      {required String title,
      required String dialogTitle,
      required String dialogMessage,
      required String status}) {
    // '이동중' 버튼을 누를 때 타이머를 시작합니다.
    if (status == 'moving') {
      startTimer();
    }

    // '도착완료' 버튼을 누를 때 타이머를 멈추고 시간을 저장합니다.


    return NextButton(
        title: title,
        onPressed: () {
          showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return RectangleDialog(
                title: dialogTitle,
                message: dialogMessage,
                okLabel: '확인',
                cancelLabel: '취소',
                okPressed: () {
                  // Firestore 업데이트 로직
                  String? docId = widget.carId ?? widget.walkId;
                  String collection = widget.carId != null ? 'cars' : 'walks';
                  if (docId != null) {
                    FirebaseFirestore.instance
                        .collection(collection)
                        .doc(docId)
                        .update({'status': status}).then((_) {
                      // 'arriving' 상태일 경우 현재 페이지를 닫음
                      if (status == 'arriving') {
                        int minutes = _elapsedTime.inMinutes;
                        FirebaseFirestore.instance
                            .collection(collection)
                            .doc(docId)
                            .update({'service_time': minutes});

                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        _timer?.cancel();

                      } else {
                        Navigator.of(context).pop();
                        // 상태 업데이트 로직 추가
                        setState(() {
                          // 다음 단계로 상태 업데이트
                          if (status == 'moving') {
                            currentStep = 2; // '도착 완료'에 해당하는 스텝 인덱스
                          } else {
                            currentStep = status == 'boarding' ? 1 : 2;
                          }
                        });
                      }
                    });
                  }
                },
              );
            },
          );
        });
  }
}
