import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pathpal/colors.dart';
import 'package:pathpal/theme.dart';
import 'package:pathpal/widgets/request_items_vt.dart';

class VtRequests extends StatefulWidget {
  const VtRequests({super.key});

  @override
  State<VtRequests> createState() => _RequestsState();
}

class _RequestsState extends State<VtRequests> {

  int? buttonState;
  int totalServiceTime = 0; // 봉사 시간 총합을 저장할 변수

  @override
  void initState() {
    super.initState();
    buttonState = 0;
    calculateTotalServiceTime(); // 초기화 시 봉사 시간 총합 계산

  }

  void calculateTotalServiceTime() async {
    final uid = FirebaseAuth.instance.currentUser!.uid; // 현재 사용자 ID
    if (uid == null) {
      print("No user logged in");
      return;
    }
    final category = buttonState == 0 ? "cars" : "walks"; // 현재 선택된 카테고리
    int total = 0; // 봉사 시간 합계를 저장할 임시 변수

    // Firestore에서 문서 가져오기 및 합계 계산
    final querySnapshot = await FirebaseFirestore.instance
        .collection(category)
        .where('vt_uid', isEqualTo: uid)
        .get();

    for (var doc in querySnapshot.docs) {
      int serviceTime = doc.data()['service_time'] ?? 0;
      total += serviceTime;
    }

    // 상태 업데이트
    setState(() {
      totalServiceTime = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "봉사 내역",
            style: appTextTheme().titleMedium,
          ),
        ),
        body: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity, //가능한 가장 큰 너비
                height: 40,
                color: Colors.white,
                child: Row(
                  children: [
                    Container(
                      width: 90,
                      height: 40,
                      decoration: BoxDecoration(
                        border:Border(
                          bottom: BorderSide(
                            color:buttonState == 0? mainAccentColor: Colors.transparent,
                          ),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () =>
                        buttonState==1
                            ? setState(() {
                          buttonState = 0;
                        })
                            : null,
                        child: Center(
                          child: Text(
                            "차량서비스",
                            style: appTextTheme()
                                .bodyMedium!
                                .copyWith(color: buttonState==0? mainAccentColor: gray400),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 90,
                      height: 40,
                      decoration: BoxDecoration(
                        border:Border(
                          bottom: BorderSide(
                            color:buttonState == 1? mainAccentColor: Colors.transparent,
                          ),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () =>
                        buttonState == 0
                            ? setState(() {
                          buttonState = 1;
                        })
                            : null,
                        child: Center(
                          child: Text(
                            "도보서비스",
                            style: appTextTheme()
                                .bodyMedium!
                                .copyWith(color: buttonState==1? mainAccentColor: gray400),
                          ),
                        ),
                      ),
                    ),
                  ],),
              ),
              Expanded(
                child: VtRequestItems(category: buttonState == 0 ? "car" : "walk"),
              ),
              Container(
                width: double.infinity, // 컨테이너를 화면 너비만큼 확장
                padding: EdgeInsets.fromLTRB(15, 5, 15, 5), // 양쪽에 15, 위아래에 10의 패딩 추가
                decoration: BoxDecoration(
                  color: Colors.white, // 배경을 흰색으로 설정
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300), // 상단에 회색 테두리선 추가
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "총 봉사시간: ${totalServiceTime}분", // 봉사 시간 총합을 표시
                      style: appTextTheme().titleMedium, // 글자 크기 키우고 색상 설정
                      textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 적립하기 버튼의 액션
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFFBFC6FA), // 버튼 배경색
                        padding: EdgeInsets.symmetric(horizontal: 10), // 버튼 내부 패딩 조절
                        shape: RoundedRectangleBorder( // 버튼 모양 설정
                          borderRadius: BorderRadius.circular(5), // 버튼의 border radius 설정
                        ),
                        fixedSize: Size(80, 20), // 버튼의 크기 설정
                      ),
                      child: Text(
                        "적립하기",
                        style: TextStyle(fontSize: 14), // 버튼의 글자 크기 설정
                      ),
                    ),
                  ],
                ),
              )
            ])

    );
  }
}