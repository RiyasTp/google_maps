import 'dart:async';
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:google_maps/map_style.dart';
import 'package:vector_math/vector_math.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);
  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage>
    with TickerProviderStateMixin {
  // final Completer<GoogleMapController> _controller = Completer();
  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  static const LatLng destination = LatLng(37.33429383, -122.06600055);

  final travelled = [sourceLocation, destination];

  final List<Marker> _markers = <Marker>[];
  Animation<double>? _animation;
  late GoogleMapController _gcontroller;

  final _mapMarkerSC = StreamController<List<Marker>>();

  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  StreamSink<List<Marker>> get _mapMarkerSink => _mapMarkerSC.sink;

  Stream<List<Marker>> get mapMarkerStream => _mapMarkerSC.stream;

  List<LatLng> polylineCoordinates = [];
  void setCustomMarkerIcon() {
  BitmapDescriptor.fromAssetImage(
          ImageConfiguration.empty, "assets/sb1.png")
      .then(
    (icon) {
      currentLocationIcon = icon;
    },
  );
}

  void getPolyPoints() async {
    dev.log('started getpolypoints');
    PolylinePoints polylinePoints = PolylinePoints();

    /// from url
    // PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    //   'AIzaSyAV9nmFBGBHAJ8OsNg1XhGNmoftJXBdyqQ', // Your Google Map Key
    //   PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
    //   PointLatLng(destination.latitude, destination.longitude),
    // );

    // print(result.status.toString());

    // if (result.points.isNotEmpty) {
    //   print('Result is not empty ');
    //   result.points.forEach(
    //     (PointLatLng point) => polylineCoordinates.add(
    //       LatLng(point.latitude, point.longitude),
    //     ),
    //   );

    //   dev.log(polylineCoordinates.toString());
    //   setState(() {});
    // }


/// from string
    List<PointLatLng> lines = polylinePoints.decodePolyline(newPoints);

    if (lines.isNotEmpty) {
      print('Result is not empty ');
      lines.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );

      dev.log(polylineCoordinates.toString());
      setState(() {});
    }

    print('completed getpolypoints');
  }

  LocationData? currentLocation;
  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );

    // GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;
        travelled.add(LatLng(newLoc.latitude!, newLoc.longitude!));
        travelled.removeAt(0);
        print(travelled.toString());
        // _gcontroller.animateCamera(
        //   CameraUpdate.newCameraPosition(
        //     CameraPosition(
        //       zoom: 13.5,
        //       target: LatLng(
        //         newLoc.latitude!,
        //         newLoc.longitude!,
        //       ),
        //     ),
        //   ),
        // );
        animateCar(
          travelled[0].latitude,
          travelled[0].longitude,
          travelled[1].latitude,
          travelled[1].longitude,
          _mapMarkerSink,
          this,
          _gcontroller,
        );

        // setState(() {});
      },
    );
  }

  @override
  void initState() {
    // getDirections(); 
    getPolyPoints();
    getCurrentLocation();
    setCustomMarkerIcon(); 
    super.initState();

    //Starting the animation after 1 second.
    // Future.delayed(const Duration(seconds: 2)).then((value) {
    //   animateCar(
    //     travelled[0].latitude,
    //     travelled[0].longitude,
    //     travelled[1].latitude,
    //     travelled[1].longitude,
    //     _mapMarkerSink,
    //     this,
    //     _gcontroller,
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => print(polylineCoordinates.toString()),
      // ),
      body: currentLocation == null
          ? const Center(child: Text("Loading"))
          : StreamBuilder<List<Marker>>(
              stream: mapMarkerStream,
              builder: (context, snapshot) {
                Set<Marker> markers = {
                  const Marker(
                    markerId: MarkerId("source"),
                    position: orginLatLng,
                  ),
                   Marker(
                    markerId: MarkerId("destination"),
                    position: destination,
                    icon: currentLocationIcon 
                  ),
                };
                final waypointMarkers = buildMarkers(waypointList);
                return GoogleMap(
                  // initialCameraPosition: CameraPosition(
                  //   target: LatLng(currentLocation!.latitude!,
                  //       currentLocation!.longitude!),
                  //   zoom: 13.5,
                  // ),

                   initialCameraPosition: const CameraPosition(
                  tilt: 90,
                    target: orginLatLng,
                    zoom: 13.5,
                  ),
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId("route"),
                      points: polylineCoordinates,
                      color: const Color(0xFF8A59A3),
                      width: 6,
                    ),
                  },
                  markers: {...waypointMarkers,...markers, ...Set<Marker>.of(snapshot.data ?? [])},
                
                  onMapCreated: (mapController) {
                    // _controller.complete(mapController);
                    _gcontroller = mapController;
                    _gcontroller.setMapStyle(mapStyle);
                    // setState(() {});
                    // getCurrentLocation();
                  },
                );
              }),
    );
  }

  animateCar(
    double fromLat, //Starting latitude
    double fromLong, //Starting longitude
    double toLat, //Ending latitude
    double toLong, //Ending longitude
    StreamSink<List<Marker>>
        mapMarkerSink, //Stream build of map to update the UI
    TickerProvider
        provider, //Ticker provider of the widget. This is used for animation
    GoogleMapController controller, //Google map controller of our widget
  ) async {
    final double bearing =
        getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));

    _markers.clear();

    var carMarker = Marker(
        markerId: const MarkerId("driverMarker"),
        position: LatLng(fromLat, fromLong),
        // icon: BitmapDescriptor.fromBytes(
        //     await getBytesFromAsset('asset/car.png', 60)),
        anchor: const Offset(0.5, 0.5),
        flat: true,
        rotation: bearing,
        draggable: false,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );

    //Adding initial marker to the start location.
    _markers.add(carMarker);
    mapMarkerSink.add(_markers);

    final animationController = AnimationController(
      duration:
          const Duration(milliseconds: 1000), //Animation duration of marker
      vsync: provider, //From the widget
    );

    Tween<double> tween = Tween(begin: 0, end: 1);

    _animation = tween.animate(animationController)
      ..addListener(() async {
        //We are calculating new latitude and printitude for our marker
        final v = _animation!.value;
        double lng = v * toLong + (1 - v) * fromLong;
        double lat = v * toLat + (1 - v) * fromLat;
        LatLng newPos = LatLng(lat, lng);

        //Removing old marker if present in the marker array
        if (_markers.contains(carMarker)) _markers.remove(carMarker);

        //New marker location
        carMarker = Marker(
            markerId: const MarkerId("driverMarker"),
            position: newPos,
            icon: currentLocationIcon, 
            // icon: BitmapDescriptor.fromBytes(
            //     await getBytesFromAsset('asset/icons/ic_car_top_view.png', 50)),
            anchor: const Offset(0.5, 0.5),
            flat: true,
            rotation: bearing,
            draggable: false);

        //Adding new marker to our list and updating the google map UI.
        _markers.add(carMarker);
        mapMarkerSink.add(_markers);

        //Moving the google camera to the new animated location.

        // controller.animateCamera(CameraUpdate.newCameraPosition(
        //     CameraPosition(target: newPos, zoom: 15.5)));
      });

    //Starting the animation
    animationController.forward();
  }

  double getBearing(LatLng begin, LatLng end) {
    double lat = (begin.latitude - end.latitude).abs();
    double lng = (begin.longitude - end.longitude).abs();

    if (begin.latitude < end.latitude && begin.longitude < end.longitude) {
      return degrees(atan(lng / lat));
    } else if (begin.latitude >= end.latitude &&
        begin.longitude < end.longitude) {
      return (90 - degrees(atan(lng / lat))) + 90;
    } else if (begin.latitude >= end.latitude &&
        begin.longitude >= end.longitude) {
      return degrees(atan(lng / lat)) + 180;
    } else if (begin.latitude < end.latitude &&
        begin.longitude >= end.longitude) {
      return (90 - degrees(atan(lng / lat))) + 270;
    }
    return -1;
  }
}

final a = [
  const LatLng(37.33500926, -122.03272188),
  const LatLng(37.33500926, -122.03272188),
  const LatLng(37.3316708, -122.0309575),
  const LatLng(37.3316935, -122.0311145),
  const LatLng(37.3316898, -122.0317467),
  const LatLng(37.33169, -122.0321927),
  const LatLng(37.3321798, -122.032204),
  const LatLng(37.3326875, -122.0321819),
  const LatLng(37.333259, -122.0321802),
  const LatLng(37.3338922, -122.0321909),
  const LatLng(37.3344598, -122.0321901),
  const LatLng(37.3348196, -122.0321935),
  const LatLng(37.3347392, -122.0341598),
  const LatLng(37.3342937, -122.0364338),
  const LatLng(37.3344162, -122.0387874),
  const LatLng(37.3344079, -122.0411914),
  const LatLng(37.3344086, -122.0437783),
  const LatLng(37.3343956, -122.0461836),
  const LatLng(37.3341121, -122.0484636),
  const LatLng(37.3335669, -122.0510303),
  const LatLng(37.333095, -122.0532199),
  const LatLng(37.3326124, -122.0555251),
  const LatLng(37.3323166, -122.0577965),
  const LatLng(37.3325228, -122.0601192),
  const LatLng(37.3332143, -122.0623253),
  const LatLng(37.3340605, -122.0647482),
  const LatLng(37.3345217, -122.0656906),
  const LatLng(37.3351755, -122.0666213),
  const LatLng(37.3357105, -122.0675788),
  const LatLng(37.3364929, -122.068061),
  const LatLng(37.337507, -122.0682945),
  const LatLng(37.3386435, -122.069021),
  const LatLng(37.3394062, -122.0698694),
  const LatLng(37.3402564, -122.0709996),
  const LatLng(37.3410622, -122.0720415),
  const LatLng(37.3412282, -122.0726797),
  const LatLng(37.340984, -122.0732774),
  const LatLng(37.3406894, -122.0737016),
  const LatLng(37.3401269, -122.0741251),
  const LatLng(37.3396549, -122.0745196),
  const LatLng(37.3392092, -122.0747958),
  const LatLng(37.3387956, -122.0750786),
  const LatLng(37.3381889, -122.0754786),
  const LatLng(37.3377188, -122.0756249),
  const LatLng(37.3371947, -122.0760024),
  const LatLng(37.3367699, -122.0763551),
  const LatLng(37.3362494, -122.0766471),
  const LatLng(37.3357095, -122.0766845),
  const LatLng(37.3352071, -122.0766573),
  const LatLng(37.3348482, -122.0764891),
  const LatLng(37.3342498, -122.0761984),
  const LatLng(37.334257, -122.0762127),
  const LatLng(37.3342582, -122.0762147),
  const LatLng(37.3342565, -122.0762144),
  const LatLng(37.3342582, -122.0762147),
  const LatLng(37.3342517, -122.0762145),
  const LatLng(37.3342579, -122.0762146),
  const LatLng(37.3342583, -122.0762147),
];

Future<String> getDirections() async {
  try {
    var response = await Dio().get(url);
    dev.log(response.data.toString());
    dev.log('================++++++++++++++++==============');
    dev.log(response.data['routes'][0]['overview_polyline']);
    dev.log('================++++++++=====++++++++==============');
 
  return response.data['routes'][0]['overview_polyline'].toString();
  } catch (e) {
    e;
    return '';
  } finally {
    print('completed');
  }
}

const baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
const destination = 'Perth%2C%20AU';
const origin = 'Sydney%2C%20AU';
const waypoints = 'via%3A-37.81223%2C144.96254%7Cvia%3A-34.92788%2C138.60008';
const YOUR_API_KEY = 'AIzaSyAV9nmFBGBHAJ8OsNg1XhGNmoftJXBdyqQ';

const orginLatLng = LatLng(13.0102061,
    80.2373687); // https://www.google.co.in/maps/place/IIT+Madras+Main+Gate/@13.0102061,80.2373687,16.43z/
const destinationLatLng = LatLng(13.030168, 80.276943);
const waypointList = [
  LatLng(13.018715, 80.261715),
  LatLng(13.018361, 80.262911),
  LatLng(13.017977, 80.265262),
  LatLng(13.021781, 80.268653),
  LatLng(13.023035, 80.268724),
  LatLng(13.024053, 80.274210),
  LatLng(13.026115, 80.276781),
  LatLng(13.028307, 80.276398),
  LatLng(13.028258, 80.278792),
  LatLng(13.030168, 80.276943),

  LatLng(13.032044, 80.277603),
  LatLng(13.037806, 80.264601),
  LatLng(13.041761, 80.279532),
  
  
];

final stops = encodeWayPoints(waypointList);
final originStr = '${orginLatLng.latitude},${orginLatLng.longitude}';
final destStr ='${destinationLatLng.latitude},${destinationLatLng.longitude}';


final url =
    '$baseUrl?destination=$destStr&origin=$originStr&waypoints=$stops&key=$YOUR_API_KEY';


//from googlemaps
const encodingStr =
    'quhrF`rqWcHzBaNzDeG~A][?k@lA{Dr@mBR]HmA[WQDWE[g@mAeE?]QOeAcE[_EEuKHMCo@_@IyBoAgAYUd@KXWDmMUqFWKWi@ASR]L}A@yM[yEe@cCs@uCiAcCUiCAmBa@sDsAcCUcKHgLB}EScJ_BwLwCsOkCaQaEgOsDmIwCuGkCuJeE}DcCeG{CkPiGgx@eZuUyIeNyEwNcCcOoC_V{HcHuAkFeAaCy@uGiDeKiH{GuDmV}PcIwCaM}DqY{QuE_D_IyGoOmIwGqEoO}KqZoRqX_RqpA_z@qe@{ZgIoEgNgF{IqBqN_BsGOeGD}SrAwDTkIJqFa@oFmA_FuBqEyCcEaEkDaFqC{FmCqH{DwMiPij@kEyLkJcSwE_IaGmIgIoJkP_Oau@kl@a_A}t@i[}VwQyNkN}KoLkLu_@o`@cXyXiB_CuAoCkBcHyIqv@yIiw@i@sEmB_OoBgHcAeCuFeJsGiGqJcFoa@uRge@iUwb@mXaMcIyEoDqDmDqHcKsFkKmEiHyEmFqE}DuJaGgCoA_HuBiQkEk^cJim@qOoc@aO}HoCyOyGgHkCmHuBuL{BaMoByKeD_T_IaGcCkE{BuPwG_T_IaL}CoLeEqToJue@iQwm@aUi]iMkMyE{FeCyDqCaBgBoBwCgC{FgEiMoTip@gDeFaDiCcBw@yBk@eDYsCHyG`AwRlD_XvEsEf@iCGqDe@oBo@gCqAgCoBaVkRoA_A{IsGaHyCoD}@gGs@{WuAgTiA_N{@mMuBu]eI}_@{I_IwByCuAmEeDcEmFsBoEoB{G_BqIwEaWw@sCmDoHoCiDmCaCwE_CuIkC{E_B_D{AqPwJem@g^q|Aa~@iNiI_LaG}UkNeIyEmCqAoCs@oBMkDPi`@bGob@xGoEd@wDCmCi@wBkAgO_Ma^wYqc@{^cKqIiEcDqCgAiDa@gRy@{Fa@}Nq@iGYmXeB{^uC}JeAsOqAc^}B{v@gFeZqAuYgBwm@}DkGmA}EcAwCaAsBkA_B}AsE{EuGcH}BiC_DaGqGiTsBiE_CwCaEoDyI{HeCyB]q@KeAHm@jAyAbAKb@^J\\CjA_CnG_@fBSdCcBbJoCrKkDbJgFnIyAfCeAdFiAtHVnHHjFc@hD[j@k@`@y@HcAG{Af@sAvAu@pBSVY`@kA\\e@D{@HqCTeCJsDSuHuBqA_@oFc@wCFqFFkIi@_Fc@m@GBu@@mEB}FBkG@{I?sQ?mAo@?g@tBKFY_@uAFEm@m@FMoAOcB_@kD_AaGs@eFqAsQ';

// chennai
const newPoints ="o_lnAokvhN\\CJu@j@?AGLsAg@KAAAAZyEa@ECE?E?[XwCgB@_DF?UxA?|CE|EBdDJbAHfBLLu@PgC@q@@sFFe@AoIKoO@wB?a@EeEEiEAiDBwAB]f@uE@}FK_E?aBAmHCgAIu@[mAs@qAKM_@_@m@e@mB{@_@Km@Ge@CqEAeACuAA}EAoSUmBKk@KkAa@iAo@}CeBwC_B}AeAy@g@[]k@e@gBaBoAsA_@We@S?]DMLM|FZLX^fD@h@GLIJGDSDgA_A{B{BYYc@UQGAUBMPUnGXpBDqBECZ^fD@h@GLIJGDSDgA_A{B{BYYc@UQGAUBMPU|FZKeBQkC?m@bAmF~Cx@FBGC_Dy@TmBCkAUaCK_@Ye@cCeDwAkBqBoC{@t@aDnC}BrBw@x@s@u@ECOGQIh@_CgA{@zAoAp@q@v@s@xCyBSW{@qAa@m@qIeMk@aA}BgCSK{E_BDQfBh@vBt@\\PnBbCJPEJKM}BgCSK{E_B}FsBk@UvA{Cp@_Bt@Jv@\\w@]u@Kq@~AwAzCeAa@{DiABMzDjAfA`@EJeAa@{DiABMRyALaAPqAL_AHeCBk@Cj@IdC_@pCa@zCCLUOECkDu@kAUa@K@Q";
const newPointss ="etonA_~}hNBMNiABOHk@BUFa@D_@@E@I@ODQBW@E@e@@G@e@Bq@@]@M";

Set<Marker> buildMarkers(List<LatLng> waypointList) {
  final Set<Marker> markers = {};
  int c =1;
  for (var point in waypointList) {
    markers.add(Marker(
      markerId: MarkerId("destination-$c"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      position: point,
    ));
    c++;
  }
  return markers; 
  // return {};
}
String encodeWayPoints(List<LatLng> waypointList){
  String data = '';
for (var point in waypointList) {
   data ='$data%7C${point.latitude}%2C${point.longitude}';
  }
  return data;
}
