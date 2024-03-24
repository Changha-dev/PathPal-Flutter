import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pathpal/colors.dart';
import 'package:pathpal/models/disabledPerson.dart';
import 'package:pathpal/screens/dp/login.dart';
import 'package:pathpal/service/firestore/user_service.dart';
import 'package:pathpal/widgets/custom_dropdown.dart';
import 'package:pathpal/widgets/navbar.dart';
import 'package:pathpal/widgets/next_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DpSignUp2 extends StatefulWidget {
  final UserCredential? userCredential;
  String? name;
  String? phoneNumber;

  DpSignUp2({super.key, this.userCredential, this.name, this.phoneNumber});

  @override
  State<DpSignUp2> createState() =>
      _DpSignUp2State(userCredential, name, phoneNumber);
}

class _DpSignUp2State extends State<DpSignUp2> {
  final firebaseService = UserService();

  bool _isButtonEnabled = true;

  final UserCredential? userCredential;
  String? name;
  String? phoneNumber;
  String? disabilityType;
  String? wcUse;

  _DpSignUp2State(this.userCredential, this.name, this.phoneNumber);

  File? _image; // 사용자가 선택한 이미지 파일을 저장할 변수
  final picker = ImagePicker();
  // 이미지를 선택하는 함수.
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // 선택한 이미지를 _image에 저장
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void _validateFields() {
    setState(() {
      _isButtonEnabled = disabilityType != null &&
          wcUse != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: 1,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '회원가입',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '필요한 서비스를 받을 수 있도록 기본 정보를 입력해주세요.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '장애정보',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // 드롭다운 버튼.
                        CustomDropDown(
                            onValueChanged: (value){
                              setState(() {
                                disabilityType = value;
                              });
                              _validateFields();
                            }
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          '휠체어 사용여부',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    wcUse = "Yes";
                                  });
                                  _validateFields();
                                },
                                style: OutlinedButton.styleFrom(
                                  fixedSize: Size(MediaQuery.of(context).size.width/2, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  side: BorderSide(
                                    color: wcUse == "Yes"
                                        ? mainAccentColor
                                        : gray200, // 원하는 색상 값 설정
                                  ),
                                ),
                                child: Text(
                                  "예",
                                  style: TextStyle(
                                    color:
                                    wcUse == "Yes" ? mainAccentColor : gray200,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    wcUse = "No";
                                  });
                                  _validateFields();
                                },
                                style: OutlinedButton.styleFrom(
                                  fixedSize: Size(
                                      MediaQuery.of(context).size.width / 2, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  side: BorderSide(
                                    color: wcUse == "No" ? mainAccentColor : gray200, // 원하는 색상 값 설정
                                  ),
                                ),
                                child: Text(
                                  "아니오",
                                  style: TextStyle(
                                    color:
                                    wcUse == "No" ? mainAccentColor : gray200,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          '장애인 복지카드 등록',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        OutlinedButton(
                          onPressed: _pickImage,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _image == null ? Colors.grey : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          child: Text(
                            _image == null ? '사진 업로드' : '사진 변경',
                            style: TextStyle(
                              color: _image == null ? Colors.grey : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        if (_image != null)
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            height: 200, // 이미지 높이
                            alignment: Alignment.center,
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width, // 화면 너비에 맞춰 이미지 조절
                            ),
                          ),

                      ],

                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: NextButton(
            title: "가입완료",
            onPressed: _isButtonEnabled ? _goToNextPage : null
        )
    );
  }

  void _goToNextPage() {
    if (userCredential != null && userCredential?.user != null) {
      DisabledPerson dp = DisabledPerson(
          uid: userCredential?.user?.uid,
          profileUrl: userCredential?.user?.photoURL,
          email: userCredential?.user?.email,
          name: name,
          phoneNumber: phoneNumber,
          disabilityType: disabilityType,
          wcUse: wcUse);
      firebaseService.saveDisabledPerson(dp)
          .then((isSuccess) {
        if (isSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DpNavBar()),
          );
        } else {
          // 회원 정보 저장 실패 시 로그인 창으로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DpLogin()),
          );
        }
      });
    } else {
      print("Null 발생");
    }


  }
}
