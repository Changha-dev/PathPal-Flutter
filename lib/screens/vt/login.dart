
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pathpal/colors.dart';
import 'package:pathpal/screens/dp/login.dart';
import 'package:pathpal/screens/vt/signup_1.dart';
import 'package:pathpal/widgets/navbar_vt.dart';

import '../../service/auth_service.dart';
import '../../service/firestore/user_service.dart';
import 'car_main.dart';

class VtLogin extends StatefulWidget {

  VtLogin({super.key});

  @override
  State<VtLogin> createState() => _VtLoginState();
}

class _VtLoginState extends State<VtLogin> {
  final authService = AuthService();

  final userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 70,
                  ),
                  Column(
                    children: [
                      Text(
                        '장애 전용 교통지원 서비스',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'PathPal',
                        style: TextStyle(
                            fontSize: 48,
                            fontFamily: "login",
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      Text(
                        'for Volunteers',
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 270,
                    height: 270,
                    child: Image.asset('assets/images/logo.png'),
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: 279,
                        height: 44,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              surfaceTintColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              elevation: 0.0,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              )),
                          icon: Image.asset(
                            'assets/images/google-icon.png',
                            height: 20,
                          ),
                          onPressed: () async {
                            final userCredential =
                                await authService.signInWithGoogle();

                            if (userCredential != null) {
                              await updateTokenAndNavigate(context, userCredential);
                              if (await userService
                                      .checkVtUser(userCredential.user!.uid) ==
                                  true) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VtNavBar(
                                            vtUid: userCredential.user!.uid,
                                          )),
                                  (route) => false,
                                );
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => VtSignUp(
                                            userCredential: userCredential)));
                              }
                            }
                          },
                          label: Text(
                            '구글 계정으로 시작하기',
                            style: TextStyle(color: gray600),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        '장애인사용자 이신가요?',
                        style: TextStyle(fontSize: 14, color: gray600),
                      ),
                      GestureDetector(
                          child: Text(
                            'Go to Original PathPal',
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w100),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DpLogin()));
                          })
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  updateTokenAndNavigate(BuildContext context, UserCredential userCredential) async {
    String? token = await FirebaseMessaging.instance.getToken();

    // 토큰과 사용자 정보를 Firestore에 저장
    await saveTokenToDatabase(token!, userCredential.user!.uid);

    // 사용자의 로그인 상태에 따라 적절한 화면으로 이동
    bool isNewUser = await userService.checkDpUser(userCredential.user!.uid);
    if (isNewUser) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VtSignUp(userCredential: userCredential)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VtNavBar(vtUid: userCredential.user!.uid)),
      );
    }
  }

  saveTokenToDatabase(String token, String uid) async {
    // 토큰과 사용자 UID를 사용하여 Firestore에 저장
    if (token != null) {
      await FirebaseFirestore.instance.collection('volunteers').doc(uid).set({
        'token': token,
        'lastSeen': DateTime.now(),
      }, SetOptions(merge: true)); // 기존 문서에 병합
    }
  }
}
