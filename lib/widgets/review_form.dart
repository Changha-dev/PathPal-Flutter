import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pathpal/models/review.dart';
import 'package:pathpal/service/firestore/review_service.dart';
import 'package:pathpal/widgets/build_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pathpal/widgets/navBar.dart';
import 'package:pathpal/widgets/next_button.dart';

class ReviewForm extends StatefulWidget {
  final String dpUid;
  final String vtUid;
  final String reqId;
  final String category;
  const ReviewForm(
      {super.key,
      required this.dpUid,
      required this.vtUid,
      required this.reqId,
      required this.category});

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  double _rating = 0.0;
  final _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reviewController.addListener(_updateState);
  }

  void _updateState() {
    // 리뷰 텍스트가 변경될 때마다 상태를 업데이트합니다.
    setState(() {});
  }

  final firebaseService = ReviewService();
  void _addReview() {
    //현재 로그인된 uid 가져오기
    final dpUid = FirebaseAuth.instance.currentUser!.uid;
    ReviewModel review = ReviewModel(
        dpUid: dpUid,
        vtUid: widget.vtUid,
        category: widget.category,
        reqId: widget.reqId,
        content: _reviewController.text,
        rating: _rating);

    firebaseService.saveReviewData(review).then((isSuccess) {
      if (isSuccess) {
        Fluttertoast.showToast(
          msg: '리뷰가 성공적으로 등록되었어요!',
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Container(child: DpNavBar()),
            ));
      } else {
        // 회원 정보 저장 실패 시 로그인 창으로 이동
        print("저장 실패 오류");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('volunteers')
                .doc(widget.vtUid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator(); // 데이터가 로딩 중일 때 보여줄 위젯
              }
              Map<String, dynamic> vtData = snapshot.data!.data() as Map<String, dynamic>;
              return  Expanded(
                    child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //프로필 이미지
                               SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: ClipOval(
                                    child: BuildImage.buildProfileImage(
                                        vtData['profileUrl']),
                                  ),
                                ),
                                Text('${vtData['name']}봉사자와의 이동은 어떠셨나요?'),
                                //별점
                                RatingBar.builder(
                                  initialRating: 0,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                    setState(() {
                                      _rating = rating;
                                    });
                                  },
                                ),
                                //TextField
                                TextField(
                                  controller: _reviewController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                   contentPadding: EdgeInsets.symmetric(vertical: 40, horizontal: 10)
                                  ),
                                ),
                              ]),
                        ),
                  
                )
              );
            }),
            NextButton(
              title: "작성완료",
              onPressed: _rating > 0 && _reviewController.text.isNotEmpty
                  ? () => {_addReview()}
                  : null,
            )  
      ],
    ),
    );
  }
}
