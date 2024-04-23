import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pathpal/colors.dart';
import 'package:pathpal/screens/vt/walk_detail.dart';
import 'package:pathpal/widgets/appBar.dart';
import 'package:pathpal/widgets/google_map.dart';
import 'package:pathpal/widgets/next_button.dart';

import '../../service/map_service.dart';
import '../../theme.dart';
import '../../utils/app_images.dart';
import '../../utils/format_time.dart';
import '../../widgets/build_image.dart';
import '../../widgets/dp_info.dart';
import '../../widgets/item_info_list.dart';

class WalkMain extends StatefulWidget {
  final String? vtUid;
  const WalkMain({Key? key, required this.vtUid}) : super(key: key);

  @override
  State<WalkMain> createState() => _WalkMainState();
}

class _WalkMainState extends State<WalkMain> {
  late GoogleMapController mapController;
  final MapService mapService = MapService();
  final Set<Marker> _markers = {};
  List<Map<String, LatLng>> items = [];
  LatLng? _center;
  static bool isMarkerMain = true;
  final Completer<GoogleMapController> _controllerCompleter = Completer(); // Completer를 추가하세요.


  @override
  Widget build(BuildContext context) {
    if (_center == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: MyAppBar(
        title: "PathPal",
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('walks').where('status', isEqualTo: 'waiting').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final currentLocationMarker = _markers.firstWhereOrNull((marker) => marker.markerId.value == 'myLocation');

          _markers.clear();

          if (currentLocationMarker != null) {
            _markers.add(currentLocationMarker);
          }

          snapshot.data?.docs.forEach((doc) {
            Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
            if (data != null) {
              GeoPoint geoPoint = data['departure_latlng'];
              LatLng location = LatLng(geoPoint.latitude, geoPoint.longitude);
              _markers.add(
                Marker(
                  markerId: MarkerId(data['departure_address']),
                  position: location,
                  icon: BitmapDescriptor.defaultMarker,
                  onTap: () {
                    if (isMarkerMain == true) {
                      _onMarkerTapped(doc);
                    }
                  },
                ),
              );
            }
          });

          return MyGoogleMap(
            center: _center,
            currentLocationFunction: _currentLocation,
            markers: _markers,
            onMapCreated: (controller) {
              if (!_controllerCompleter.isCompleted) {
                _controllerCompleter.complete(controller); // Controller를 Completer에 연결하세요.
              }
              mapController = controller;
            },
          );
        },
      ),
    );
  }


  @override
  void initState() {
    super.initState();

    _currentLocation(); // 현재 위치 마커를 불러옵니다.

  }

  void _onMarkerTapped(DocumentSnapshot walk) {
    Set<Marker> markers = new Set();
    Marker? selectedMarker = _markers.firstWhere((marker) => marker.markerId.value == walk['departure_address']);
    markers.add(selectedMarker);

    String departureAddress = walk['departure_address'];
    DateTime date = walk['departure_time'].toDate() ?? DateTime(2024, 1, 31);

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('disabledPerson')
                .doc(walk['dp_uid'])
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              var doc = snapshot.data!;
              return InkWell(
                onTap: () async {
                  isMarkerMain = false;

                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => WalkDetail(
                        vtUid: widget.vtUid ?? '',
                        markers: markers,
                        center: _center,
                        onMapCreated: (controller) {
                          mapController = controller;
                        },
                        currentLocationFunction: _currentLocation,
                        dpSnapshot: snapshot,
                        walkSnapshot: walk,
                      )));
                  isMarkerMain = true;
                },
                child: Container(
                  width: double.infinity,
                  height: 100, // 원하는 높이로 설정
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        children: [
                          BuildImage.buildProfileImage(doc.get('profileUrl'),
                              width: 30),
                          Text(
                            doc.get('name'),
                            style: appTextTheme().labelSmall,
                          )
                        ],
                      ),
                      Flexible(
                          child: Column(
                            children: [
                              ItemInfoList(
                                imagePath: AppImages.redCircleIconImagePath,
                                label: '출발지',
                                data: departureAddress,
                              ),
                              ItemInfoList(
                                  imagePath: AppImages.timerIconImagePath,
                                  label: '출발시간',
                                  data: FormatTime.formatTime(
                                    date,
                                  )),
                            ],
                          ))
                    ],
                  ),
                ),
              );
            });
      },
    );
  }



  void _currentLocation() async {
    final currentLocation = await mapService.getCurrentLocation();

    setState(() {
      _center = currentLocation;
      _markers.add(
        Marker(
          markerId: MarkerId('myLocation'),
          position: _center!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          alpha: 0.8,
          onTap: () {},
        ),
      );
    });
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: _center!,
        zoom: 15.0,
      ),
    ));
  }

}
