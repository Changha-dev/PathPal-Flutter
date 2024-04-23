import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pathpal/theme.dart';

import '../../colors.dart';

class VtReview extends StatelessWidget {
  final DocumentSnapshot data;

  const VtReview({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("리뷰 내역", style: appTextTheme().titleMedium,),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 50), //위에서 아래로 200만큼 떨어진 곳
          Container(
            width: double.infinity,
            height: 500, //height 500정도
            color: Colors.white, //흰색 Box
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reviews')
                    .where('req_id', isEqualTo: data.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    //아직 리뷰 작성되지 않음
                    return Center(child: Text("아직 리뷰가 작성되지 않았습니다."));
                  }

                  var reviewData = snapshot.data!.docs;
                  var rating = reviewData[0]['rating'];
                  var content = reviewData[0]['content'];

                  return Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 0),
                    child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('disabledPerson')
                            .doc(data['vt_uid'])
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          Map<String, dynamic> dpData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          var userData = snapshot.data!.data();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // 시작점을 기준으로 정렬
                            children: [
                              Text(
                                "${dpData['name']}님이 보낸 \n 따뜻한 리뷰가 도착했어요.",
                                style: appTextTheme().titleLarge,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    RatingBar.builder(
                                      initialRating: rating,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemSize: 40.0,
                                      itemPadding:
                                          EdgeInsets.symmetric(horizontal: 0.7),
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: mainAccentColor,
                                      ),
                                      onRatingUpdate: (rating) {
                                        print(rating);
                                      },
                                      ignoreGestures:
                                          true, // 사용자의 터치를 무시하려면 true로 설정
                                    ),
                                    SizedBox(
                                      width: 20.0,
                                    )
                                  ]),
                              SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 20.0), // 왼쪽으로부터 20픽셀 떨어지도록 설정
                                child: Container(
                                  width: 350,
                                  height: 300,
                                  decoration: BoxDecoration(
                                      color: Colors.white, // 원하는 배경 색
                                      border: Border.all(color: gray200), // 원하는 테두리 색
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      "${content}", style: appTextTheme().bodyLarge,),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
