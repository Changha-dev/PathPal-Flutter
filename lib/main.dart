import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pathpal/screens/dp/car/car_page.dart';
import 'package:pathpal/screens/dp/progress.dart';
import 'package:pathpal/screens/dp/login.dart';
import 'package:pathpal/screens/dp/walk/walk_page.dart';
import 'package:pathpal/screens/vt/car_main.dart';
import 'package:pathpal/screens/vt/login.dart';
import 'package:pathpal/screens/vt/progress_1.dart';
import 'package:pathpal/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pathpal/widgets/navbar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';

void main() async {
 
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, //파이어베이스 연결 코드
  );
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  initializeDateFormatting().then((_) => runApp(MyApp()));
  String? token = await FirebaseMessaging.instance.getToken();
  print("token: $token");
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('ko', 'KO'),
        title: 'pathpal',
        theme: ThemeData(
          colorScheme: appColorScheme(), // 컬러 테마 적용
          textTheme: appTextTheme(), //폰트 테마 적용
          useMaterial3: true,
        ),
        home: DpLogin(),
        routes: {
          '/CarPage': (context) => CarPage(),
          '/WalkPage': (context) => WalkPage()
        } //Disabled persion 로그인 화면
    );
  }
}
