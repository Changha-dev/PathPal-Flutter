import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:pathpal/colors.dart';
import 'package:pathpal/screens/dp/progress.dart';
import 'package:pathpal/theme.dart';
import 'package:pathpal/utils/app_images.dart';
import 'package:pathpal/widgets/build_image.dart';

class RequestItems extends StatefulWidget {
  final category;
  const RequestItems({super.key, required this.category});

  @override
  State<RequestItems> createState() => _RequestItemsState();
}

class _RequestItemsState extends State<RequestItems> {
  //현재 로그인 중인 사용자 id 가져오기
  final dpUid = FirebaseAuth.instance.currentUser!.uid;
  //디버그용
  // final dpUid = "vX4hHeFUvBPJJ03p6vFP9ItEsdy1";
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(widget.category == 'car' ? 'cars' : 'walks')
            .where('dp_uid', isEqualTo: dpUid)
            .orderBy('departure_time', descending: true) // 출발 시간에 따라 최신순으로 정렬
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator()); // 데이터가 로딩 중일 때 보여줄 위젯
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot item = snapshot.data!.docs[index];
              print(item['status']);

              Map<String, String> statusCarMap = {
                'waiting': "접수완료 및 수락대기",
                'going': "수락완료",
                'boarding': "이동중",
                'arriving': '도착완료'
              };
              Map<String, String> statusWalkMap = {
                'waiting': "접수완료 및 수락대기",
                'going': "수락완료",
                'boarding': "이동중",
                'arriving': "미팅완료"
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
                            ? statusCarMap[item['status']]!
                            : statusWalkMap[item['status']]!,
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
                        widget.category)
              ]);
            },
          );
        });
  }
}

Widget _buildNotBoardingItem(String status, String formattedDepartureTime,
    DocumentSnapshot data, BuildContext context, String category) {
  return  Container(
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
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            BuildImage.buildImage(
                                AppImages.circleIconImagePath),
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
                          builder: (context) =>
                              Progress(docId: data.id, category: category)),
                    ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end, // 여기를 수정했습니다.
                    children: [
                      Text(
                        "진행상태 보기",
                        style: appTextTheme()
                            .bodyMedium!
                            .copyWith(color: mainAccentColor),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: mainAccentColor,
                      )
                    ]))
          ]));
}

Widget _buildBoardingItem(String status, String formattedDepartureTime,
    DocumentSnapshot data, String category) {
  print("buildBoarding item");

  return Container(
      color: Colors.white,
      width: double.infinity,
      height: 200,
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center, 
                    children: [
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
                .collection('volunteers')
                .doc(data['vt_uid'])
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
                  child: Row(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              Text(
                                vtData['name'],
                                style: appTextTheme().bodyMedium,
                              ),
                              category == 'car'
                                  ? Text(
                                      vtData['carNumber'],
                                      style: appTextTheme()
                                          .labelSmall!
                                          .copyWith(color: subAccentColor),
                                    )
                                  : SizedBox.shrink(),
                              //리뷰
                              StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('reviews')
                                      .where('req_id', isEqualTo: data.id)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if(!snapshot.hasData){
                                      return SizedBox.shrink();
                                    }
                                    if (snapshot.data!.docs.isEmpty) {
                                      //아직 리뷰 작성되지 않음
                                      return GestureDetector(
                                          onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Progress(
                                                            docId: data.id,
                                                            category:
                                                                category)),
                                              ),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .start, // 여기를 수정했습니다.
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "리뷰 작성하기",
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
                                    }
                                    print(snapshot.hasData);
                                    DocumentSnapshot item =
                                        snapshot.data!.docs.first;

                                    return Row(children: [
                                      Text("내 평가"),
                                      SizedBox(width: 5),
                                      RatingBar.builder(
                                        initialRating: item[
                                            'rating'], // DocumentSnapshot에서 가져온 평점
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: 20.0,
                                        itemPadding: EdgeInsets.symmetric(
                                            horizontal: 0.7),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: mainAccentColor,
                                        ),
                                        onRatingUpdate: (rating) {
                                          print(rating);
                                        },
                                        ignoreGestures:
                                            true, // 사용자의 터치를 무시하려면 true로 설정
                                      )
                                    ]);
                                  })
                            ])
                        
                      ]));
            })
      ]));
}
