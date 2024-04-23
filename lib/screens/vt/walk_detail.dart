import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pathpal/screens/vt/progress_1.dart';

import '../../colors.dart';
import '../../utils/dp_data.dart';
import '../../utils/format_time.dart';
import '../../widgets/dp_info.dart';
import '../../widgets/google_map.dart';
import '../../widgets/modal_bottom_sheet.dart';
import '../../widgets/next_button.dart';

class WalkDetail extends StatefulWidget {
  const WalkDetail({
    super.key,
    required this.vtUid,
    this.center,
    required this.markers,
    this.onMapCreated,
    this.currentLocationFunction,
    required this.dpSnapshot,
    required this.walkSnapshot,
  });

  final String vtUid;
  final LatLng? center;
  final Set<Marker> markers;
  final Function? onMapCreated;
  final Function? currentLocationFunction;
  final AsyncSnapshot<DocumentSnapshot<Object?>> dpSnapshot;
  final DocumentSnapshot walkSnapshot;

  @override
  State<WalkDetail> createState() => _WalkDetailState();
}

class _WalkDetailState extends State<WalkDetail> {
  @override
  Widget build(BuildContext context) {
    DpData.setWalkData(widget.dpSnapshot, widget.walkSnapshot);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        backgroundColor: background,
        toolbarHeight: 30.0,
      ),
      body: Column(
        children: [
          DpInfoWithComment(backgroundColor: background),
          Expanded(
            child: MyGoogleMap(
              markers: widget.markers,
              center: widget.center,
              onMapCreated: widget.onMapCreated,
              currentLocationFunction: widget.currentLocationFunction,
            ),
          ),
          NextButton(
            title: "요청 수락하기",
            onPressed: () {
              ModalBottomSheet.show(
                context,
                timeTitle: '도착시각',
                nextButtonTitle: '다음',
                onPressedToFirestore: (selectedDate) {
                  FirebaseFirestore.instance
                      .collection('walks')
                      .doc(widget.walkSnapshot.id)
                      .update({
                    'volunteer_time': selectedDate,
                    'vt_uid': widget.vtUid,
                    'status': "going"
                  }).then((_) => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VtProgress(
                                    walkId: widget.walkSnapshot.id,
                                    arriveTime:
                                        FormatTime.formatTime(selectedDate) +
                                            " 도착 예정",
                                    isWalkService: true,
                                    currentStatus: "going",
                                  ))).catchError(
                          (error) => print('Update failed: $error')));
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
