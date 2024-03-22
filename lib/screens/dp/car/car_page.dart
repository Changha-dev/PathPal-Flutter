import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pathpal/colors.dart';
import 'package:pathpal/models/car_model.dart';
import 'package:pathpal/screens/dp/progress.dart';
import 'package:pathpal/screens/dp/car/car_search.dart';
import 'package:pathpal/utils/app_images.dart';
import 'package:pathpal/widgets/build_image.dart';
import 'package:pathpal/widgets/departure_time.dart';
import 'package:pathpal/widgets/google_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pathpal/service/map_service.dart';
import 'package:pathpal/widgets/next_button.dart';
import 'package:pathpal/models/car_state.dart';
import 'package:pathpal/service/firestore/car_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class CarPage extends StatefulWidget {
  const CarPage({super.key});

  @override
  State<CarPage> createState() => _CarPage();
}

class _CarPage extends State<CarPage> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  final MapService mapService = MapService();
  LatLng? _center;
  String? departureAddress = CarServiceState().departureAddress;
  LatLng? departureLatLng = CarServiceState().departureLatLng;
  String? destinationAddress = CarServiceState().destinationAddress;
  LatLng? destinationLatLng = CarServiceState().destinationLatLng;
  DateTime? departureTime;

  bool areDepartureAndDestinationSet() {
    // 출발지와 목적지가 모두 설정되었는지 확인
    return CarServiceState().departureAddress != null &&
        CarServiceState().destinationAddress != null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      flutterDialog();
    });
    // flutterDialog();
    if (departureLatLng != null && destinationLatLng != null) {
      setState(() {
        _center = departureLatLng;
      });
      _onMapCreated(departureLatLng!, destinationLatLng!);
    }
    CarServiceState().departureAddress ?? _getcurrentLocation();
    CarServiceState().departureTime =
        CarServiceState().departureTime ?? DateTime.now();
  }

   void flutterDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Dialog를 제외한 다른 화면 터치를 막음
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10.0)), // Dialog 화면 모서리 둥글게 조절
          title: Text("잠깐! 전동 휠체어를 이용하시나요?"),
          content: SingleChildScrollView(
            // 내용이 길 경우 스크롤 가능하도록 설정
            child: ListBody(
              children: <Widget>[
                Text(
                  "안녕하세요, PathPal을 이용해 주셔서 감사합니다. 🌟\n\n"
                  "우리 서비스는 민간 자원봉사자들의 차량을 이용한 교통 지원 서비스를 제공하고 있습니다. "
                  "하지만 아쉽게도 현재 제공되는 차량으로는 전동휠체어의 탑승이 어려운 점 양해 부탁드립니다.\n\n"
                  "전동휠체어를 사용하시는 경우, 보다 안전하고 편리한 이동을 위해 '장애인 콜택시' 서비스 이용을 권장드립니다. "
                  "장애인 콜택시는 전동휠체어 탑승이 가능하도록 특별히 설계된 차량을 제공하여, 여러분의 이동을 도와드립니다.\n\n"
                  "장애인 콜택시 이용 방법 안내:",
                ),
                 GestureDetector(
                    onTap: () {
                      _launchURL('https://www.sndcc.org/mobile/main/contents.do?menuNo=300035');
                    },
                    child: Text(
                      "https://www.sndcc.org/mobile/main/contents.do?menuNo=300035",
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                ),
                Text(
                    "\n저희 PathPal은 앞으로도 더 많은 분들이 편리하게 이동할 수 있도록 서비스 개선에 최선을 다하겠습니다. 불편을 드려 죄송합니다. 🙏"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.pop(context); // 대화 상자를 닫음
              },
            ),
          ],
        );
      },
    );
  }

  void _launchURL(String url) async {
     if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  Future<void> _onMapCreated(LatLng departure, LatLng destination) async {
    final markers = await mapService.createMarkers(departure, destination);
    final currentLocation = await mapService.getCurrentLocation();

    setState(() {
      _markers.clear();
      _markers.addAll(markers);
      _markers.add(
        Marker(
          markerId: MarkerId('myLocation'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          alpha: 0.8,
          position: currentLocation,
        ),
      );
    });
  }

  void _getcurrentLocation() async {
    print("_getCurrentLocation");
    final currentLatLng = await mapService.getCurrentLocation();
    print(currentLatLng);

    setState(() {
      CarServiceState().departureLatLng = currentLatLng;
      _center = CarServiceState().departureLatLng;
      print('현재 : $_center');
    });
    // 역지오코딩을 통해 현재 위치의 주소를 가져옵니다.
    final placemarks = await placemarkFromCoordinates(
        currentLatLng.latitude, currentLatLng.longitude);

    if (placemarks.isNotEmpty) {
      final placemark = placemarks.first;
      final address = '${placemark.street}';
      //주소가 너무 길 경우
      List<String> addressParts = address.split(' ');
      if (addressParts.length > 2) {
        addressParts.removeRange(0, 1); // 나라 이름 제거
      }
      setState(() {
          CarServiceState().departureAddress = addressParts.join(' '); // 현재 위치의 주소를 반환
      });
 
      print(CarServiceState().departureAddress);
    } else {
      setState(() {
        CarServiceState().departureAddress = '현 위치';
      });
    }
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

  void _goToSearch() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Container(child: Search()),
        ));
  }

  final firebaseService = CarService();

  void _submitForm() async {
    print("submitForm");
    // Firebase에서 현재 사용자의 uid 가져오기
    final dpUid = FirebaseAuth.instance.currentUser!.uid;
    CarModel car = CarModel(
        departureAddress: departureAddress,
        departureLatLng: departureLatLng,
        departureTime: CarServiceState().departureTime,
        destinationAddress: destinationAddress,
        destinationLatLng: destinationLatLng,
        dpUid: dpUid,
        status: "waiting");

    firebaseService.saveCarServiceData(car).then((docId) {
      if (docId != null) {
        CarServiceState().resetState();
        Fluttertoast.showToast(
          msg: '접수가 완료되었어요!',
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  Container(child: Progress(docId: docId, category: 'car')),
            ));
      } else {
        // 회원 정보 저장 실패 시 로그인 창으로 이동
        print("저장 실패 오류");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
                CarServiceState().resetState();
              },
              icon: Icon(Icons.arrow_back)),
          centerTitle: true,
          title: Text(
            '차량서비스',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(children: [
              Flexible(
                  child: MyGoogleMap(
                center: _center,
                markers: _markers,
                onMapCreated: (controller) {
                  mapController = controller;
                },
                currentLocationFunction: _currentLocation,
              )),
              SizedBox(
                height: constraints.maxHeight * 0.35,
                child: Column(children: [
                  DepartureTimeWidget(
                      departureTime: CarServiceState().departureTime!),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(children: [
                        GestureDetector(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              BuildImage.buildImage(
                                  AppImages.circleIconImagePath),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text("출발지 : "),
                              ),
                              Flexible(
                                  child: Text(
                                CarServiceState().departureAddress ?? '',
                                overflow: TextOverflow.ellipsis,
                              ))
                            ],
                          ),
                          onTap: () {
                            _goToSearch();
                          },
                        ),
                        SizedBox(height: 5),
                        Divider(color: gray200),
                        GestureDetector(
                          child: Row(
                            children: [
                              BuildImage.buildImage(
                                  AppImages.redCircleIconImagePath),
                              SizedBox(width: 10),
                              Text("목적지 : "),
                              Flexible(
                                  child: Text(
                                CarServiceState().destinationAddress ?? ' ',
                                overflow: TextOverflow.ellipsis,
                              ))
                            ],
                          ),
                          onTap: () {
                            _goToSearch();
                          },
                        ),
                        SizedBox(height: 5),
                        Divider(color: gray200),
                      ]),
                    ),
                  ),
                  NextButton(
                    title: "신청하기",
                    onPressed: areDepartureAndDestinationSet()
                        ? () => _submitForm()
                        : null,
                  )
                ]),
              ),
            ]);
          },
        ));
  }
}
