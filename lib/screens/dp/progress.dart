import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pathpal/colors.dart';
import 'package:pathpal/widgets/cancel_button.dart';
import 'package:pathpal/widgets/custom_dialog.dart';
import 'package:pathpal/widgets/next_button.dart';
import 'package:pathpal/widgets/progress_app_bar.dart';
import 'package:pathpal/widgets/review_form.dart';
import 'package:pathpal/widgets/stepper.dart';
import 'package:pathpal/widgets/vt_info.dart';

class Progress extends StatefulWidget {
  final docId;
  final category;
  const Progress({super.key, this.docId, this.category});

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  int _setCurrentStep(status) {
    switch (status) {
      case 'waiting':
        return 0;
      case 'going':
        return 1;
      case 'boarding':
        return 2;
      case 'arriving':
        return 3;
      default:
        return -1;
    }
  }

  void _cancelRequest(context) async {
    print("Cancel Request button pressed");
    await showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return RectangleDialog(
            title: '요청 취소',
            message: '정말로 서비스 요청을 취소하시겠습니까?',
            okLabel: '확인',
            cancelLabel: '취소',
            okPressed: () {
              FirebaseFirestore.instance
                  .collection(widget.category == 'car' ? 'cars' : 'walks')
                  .doc(widget.docId)
                  .delete()
                  .then((_) {
                Navigator.of(context)
                    .popUntil((route) => route.isFirst); //앱의 첫 페이지로 돌아감
              });
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ProgressAppBar(),
        body: Builder(builder: (BuildContext context) {
          final double appBarHeight = Scaffold.of(context).appBarMaxHeight ?? 0;
          final double screenHeight = MediaQuery.of(context).size.height;
          final double stepperHeight = (screenHeight - appBarHeight) * 0.2;
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection(widget.category == 'car' ? 'cars' : 'walks')
                .doc(widget.docId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator(); // 데이터가 로딩 중일 때 보여줄 위젯
              }
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>; // 받아온 문서의 데이터

              DateTime? vtTime;
              if (data['status'] != 'waiting') {
                vtTime = data['volunteer_time'].toDate();
              }
              final carSteps = ['접수완료 및 수락 대기 ', '수락완료', '이동중', '도착완료'];
              final walkSteps = ['접수완료 및 수락 대기 ', '수락완료','이동중', '미팅완료'];
              return Column(
                children: [
                  SizedBox(
                      height: stepperHeight,
                      child: CustomStepper(
                        steps: widget.category == 'car' ? carSteps : walkSteps,
                        currentStep: _setCurrentStep(data['status']),
                      )),
                  Expanded(
                      child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      //신청 취소 or 신청 확정 버튼
                      data['status'] == 'waiting'|| data['status'] == 'going'
                          ? CancelButton(
                              title: "신청 취소하기",
                              onPressed: () {
                                print('click');
                                _cancelRequest(context);
                              })
                          : Container(
                              width: double.infinity,
                              height: 45,
                              color: Colors.white,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                        color: gray400,
                                        Icons.check_circle,
                                        size: 18),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text("신청 확정")
                                  ]),
                            ),
                      SizedBox(
                        height: 30,
                      ),
                      // status가 going일 때 봉사자 정보 표시
                      data['status'] == 'going'
                          ? VtInfo(
                              vtUid: data['vt_uid'],
                              vtTime: vtTime!,
                              category: widget.category)
                          : Container(),

                      //status가 arriving일 때 리뷰작성 폼 표시
                      data['status'] == 'arriving'
                          ? ReviewForm(
                              dpUid: data['dp_uid'],
                              vtUid: data['vt_uid'],
                              reqId: widget.docId,
                              category: widget.category)
                          : Container()
                      
                    ],
                  )),
                ],
              );
            },
          );
        }));
  }
}
