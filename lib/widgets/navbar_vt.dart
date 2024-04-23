import 'package:flutter/material.dart';
import 'package:pathpal/colors.dart';
import 'package:pathpal/screens/dp/my.dart';
import 'package:pathpal/screens/vt/car_main.dart';
import 'package:pathpal/screens/vt/mypage.dart';
import 'package:pathpal/screens/vt/walk_main.dart';

import '../models/volunteer.dart';
import '../service/firestore/user_service.dart';

class VtNavBar extends StatefulWidget {
  final String vtUid;
  const VtNavBar({super.key, required this.vtUid});

  @override
  State<VtNavBar> createState() => _VtNavBarState();
}

class _VtNavBarState extends State<VtNavBar> {
  final firebaseService = UserService(); // UserService 인스턴스 생성
  Volunteer? volunteer;

  int selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == 0 && (volunteer?.carNumber == null)) {
      // carNumber가 없는 경우, 로직을 수행하지 않음
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("차량 번호가 없습니다. 정보를 완성해주세요.")),
      );
    } else {
      // carNumber가 있는 경우 또는 다른 탭을 선택한 경우
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadVolunteerData();
  }

  Future<void> _loadVolunteerData() async {
    volunteer = await firebaseService.getVolunteer(widget.vtUid);

    if(volunteer?.carNumber == null){
      selectedIndex = 1;
    }else{
      selectedIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            CarMain(vtUid: widget.vtUid),
            WalkMain(vtUid: widget.vtUid,),
            VtMyPage()
          ],
        ) ,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
                Icons.directions_car
            ),
            label: "차량서비스",
          ),
          BottomNavigationBarItem(
            icon: Icon(
                Icons.assist_walker
            ),
            label: "도보서비스",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
            label: "마이페이지",
          )
        ],
        currentIndex: selectedIndex,
        selectedItemColor: mainAccentColor,
        onTap: _onItemTapped,
      ),
    );

  }
}