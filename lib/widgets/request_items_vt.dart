import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:pathpal/colors.dart';
import 'package:pathpal/screens/dp/progress.dart';
import 'package:pathpal/screens/vt/progress_1.dart';
import 'package:pathpal/screens/vt/review.dart';
import 'package:pathpal/theme.dart';
import 'package:pathpal/utils/app_images.dart';
import 'package:pathpal/utils/format_time.dart';
import 'package:pathpal/widgets/build_image.dart';

class VtRequestItems extends StatefulWidget {
  final category;

  const VtRequestItems({super.key, required this.category});

  @override
  State<VtRequestItems> createState() => _RequestItemsState();
}

class _RequestItemsState extends State<VtRequestItems> {
  //현재 로그인 중인 사용자 id 가져오기
  final vtUid = FirebaseAuth.instance.currentUser!.uid;

  //디버그용
  // final vtUid = "vX4hHeFUvBPJJ03p6vFP9ItEsdy1";
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(widget.category == 'car' ? 'cars' : 'walks')
            .where('vt_uid', isEqualTo: vtUid)
            // .orderBy('departure_time', descending: true) // 출발 시간에 따라 최신순으로 정렬
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator()); // 데이터가 로딩 중일 때 보여줄 위젯
          }

          int totalServiceTime = 0; // 총 봉사 시간을 저장할 변수

          // 각 문서의 service_time을 합산
          for (var doc in snapshot.data!.docs) {
            int serviceTime = doc['service_time'] ?? 0; // service_time 필드가 없는 경우 0으로 처리
            totalServiceTime += serviceTime;
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot item = snapshot.data!.docs[index];
              print(item['status']);

              var serviceTime = 0;
              if (item['service_time'] != null) {
                serviceTime = item['service_time'];
              }

              Map<String, String> statusCarMap = {
                'waiting': "접수완료 및 수락대기",
                'going': "수락완료",
                'boarding': "탑승완료",
                'moving': "이동중",
                "arriving": "도착완료"
              };
              Map<String, String> statusWalkMap = {
                'waiting': "접수완료 및 수락대기",
                'going': "수락완료",
                'boarding': "미팅완료",
                'moving': "이동중",
                "arriving": "도착완료"
              };
              // Timestamp를 DateTime으로 변환
              DateTime departureTime =
                  (item['departure_time'] as Timestamp).toDate();
              // DateTime을 원하는 형식으로 포맷팅
              String formattedDepartureTime =
                  DateFormat('MM월 dd일 (E)').format(departureTime);

              return Column(children: [
                SizedBox(height: 15),
                item['status'] != 'arriving'
                    ? _buildNotBoardingItem(
                        widget.category == 'car'
                            ? statusCarMap[item['status']] ?? '이동중'
                            : statusWalkMap[item['status']] ?? '이동중',
                        formattedDepartureTime,
                        item,
                        context,
                        widget.category)
                    : _buildBoardingItem(
                        widget.category == 'car'
                            ? statusCarMap[item['status']]!
                            : statusWalkMap[item['status']]!,
                        formattedDepartureTime,
                        item,
                        widget.category, serviceTime)
              ]);
            },
          );
        });
  }
}

Widget _buildNotBoardingItem(String status, String formattedDepartureTime,
    DocumentSnapshot data, BuildContext context, String category) {
  return Container(
      color: Colors.white,
      width: double.infinity,
      height: 150,
      child: Column(children: [
        Container(
            width: double.infinity,
            height: 100,
            padding: EdgeInsets.fromLTRB(25, 20, 10, 0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDepartureTime,
                          style: appTextTheme().bodyMedium,
                        ),
                        Container(
                          height: 24,
                          decoration: BoxDecoration(
                              color: paleAccentColor,
                              borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5), // 원하는 패딩을 추가
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                status,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ]),
                  SizedBox(height: 10),
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    BuildImage.buildImage(AppImages.circleIconImagePath),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      data['departure_address'],
                      style: appTextTheme().bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]),
                  category == 'car'
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                              BuildImage.buildImage(
                                  AppImages.redCircleIconImagePath),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                data['destination_address'] ?? '',
                                style: appTextTheme().bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ])
                      : Container()
                ])),
        TextButton(
            onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VtProgress(
                      arriveTime: FormatTime.formatTime(
                          data['volunteer_time'].toDate()),
                      carId: category == 'car' ? data.id : null,
                      walkId: category != 'car' ? data.id : null,
                      isWalkService: category != 'car',
                      currentStatus: data['status'],
                    ),
                  ),
                ),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(
                "진행상태 보기",
                style:
                    appTextTheme().bodyMedium!.copyWith(color: mainAccentColor),
              ),
              Icon(
                Icons.chevron_right,
                color: mainAccentColor,
              )
            ]))
      ]));
}

Widget _buildBoardingItem(String status, String formattedDepartureTime,
    DocumentSnapshot data, String category, var serviceTime) {
  print("buildBoarding item");

  return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(children: [
        Container(
            width: double.infinity,
            height: 105,
            padding: EdgeInsets.fromLTRB(25, 20, 10, 10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        formattedDepartureTime,
                        style: appTextTheme().bodyMedium,
                      ),
                      Spacer(), // 왼쪽 Text와 오른쪽 Container 사이를 최대한 띄웁니다.
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: paleAccentColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              serviceTime.toString() + "분",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5), // 두 Container 사이의 간격
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: paleAccentColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              status,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    BuildImage.buildImage(AppImages.circleIconImagePath),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      data['departure_address'],
                      style: appTextTheme().bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]),
                  category == 'car'
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                              BuildImage.buildImage(
                                  AppImages.redCircleIconImagePath),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                data['destination_address'] ?? '',
                                style: appTextTheme().bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ])
                      : Container()
                ])),
        Divider(height: 1, color: gray100),
        StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('disabledPerson')
                .doc(data['dp_uid'])
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator(); // 데이터가 로딩 중일 때 보여줄 위젯
              }
              Map<String, dynamic> vtData =
                  snapshot.data!.data() as Map<String, dynamic>;
              return Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //프로필 이미지 원형으로 표시하기
                            SizedBox(
                              width: 52,
                              height: 52,
                              child: ClipOval(
                                child: BuildImage.buildProfileImage(
                                    vtData['profileUrl']),
                              ),
                            ),
                            SizedBox(width: 15),
                            //봉사자 정보
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    vtData['name'],
                                    style: appTextTheme().bodyMedium,
                                  ),
                                  Text(
                                    vtData['email'],
                                    style: appTextTheme()
                                        .labelSmall!
                                        .copyWith(color: subAccentColor),
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('reviews')
                                          .where('req_id', isEqualTo: data.id)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return SizedBox.shrink();
                                        }
                                        if (snapshot.data!.docs.isEmpty) {
                                          //아직 리뷰 작성되지 않음
                                          return SizedBox.shrink();
                                        }
                                        return GestureDetector(
                                            onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          VtReview(
                                                            data: data,
                                                          )),
                                                ),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .start, // 여기를 수정했습니다.
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "리뷰 확인하기",
                                                    style: appTextTheme()
                                                        .bodyMedium!
                                                        .copyWith(
                                                            color:
                                                                mainAccentColor),
                                                  ),
                                                  Icon(
                                                    Icons.chevron_right,
                                                    color: mainAccentColor,
                                                  )
                                                ]));
                                      })
                                  //리뷰
                                ])
                          ]),
                    ],
                  ));
            })
      ]));
}
