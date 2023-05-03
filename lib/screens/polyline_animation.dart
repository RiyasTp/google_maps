import 'dart:async';
import 'dart:developer' as dev;

import 'package:google_maps/map_style/map_style.dart';
// ignore: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class PolylineAnimationPage extends StatefulWidget {
  const PolylineAnimationPage({Key? key}) : super(key: key);
  @override
  State<PolylineAnimationPage> createState() => PolylineAnimationPageState();
}

class PolylineAnimationPageState extends State<PolylineAnimationPage>
    with TickerProviderStateMixin {
  // final Completer<GoogleMapController> _controller = Completer();
  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  static const LatLng destination = LatLng(37.33429383, -122.06600055);

  final travelled = [sourceLocation, destination];

  late GoogleMapController _gcontroller;

  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  final _mapMarkerSC = StreamController<List<Marker>>();
  Stream<List<Marker>> get mapMarkerStream => _mapMarkerSC.stream;

  List<LatLng> polylineCoordinates = [];

  void getPolyPoints() async {
    dev.log('started getpolypoints');
    PolylinePoints polylinePoints = PolylinePoints();

    /// from string
    List<PointLatLng> lines = polylinePoints.decodePolyline(newPoints);

    if (lines.isNotEmpty) {
      for (var point in lines) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }

      // dev.log(polylineCoordinates.toString());
      setState(() {});
    }

    dev.log('completed getpolypoints');
  }

  LocationData? currentLocation;

  @override
  void initState() {
    getPolyPoints();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      const Marker(
        markerId: MarkerId("source"),
        position: orginLatLng,
      ),
      Marker(
          markerId: const MarkerId("destination"),
          position: destination,
          icon: currentLocationIcon),
    };
    return Scaffold(
        body: GoogleMap(
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
      markers: {
        ...markers,
      },
      onMapCreated: (mapController) {
        _gcontroller = mapController;
        _gcontroller.setMapStyle(mapStyle);
        
      },
    ));
  }
}

const orginLatLng = LatLng(13.0102061,
    80.2373687); // https://www.google.co.in/maps/place/IIT+Madras+Main+Gate/@13.0102061,80.2373687,16.43z/

//from googlemaps
const encodingStr =
    'quhrF`rqWcHzBaNzDeG~A][?k@lA{Dr@mBR]HmA[WQDWE[g@mAeE?]QOeAcE[_EEuKHMCo@_@IyBoAgAYUd@KXWDmMUqFWKWi@ASR]L}A@yM[yEe@cCs@uCiAcCUiCAmBa@sDsAcCUcKHgLB}EScJ_BwLwCsOkCaQaEgOsDmIwCuGkCuJeE}DcCeG{CkPiGgx@eZuUyIeNyEwNcCcOoC_V{HcHuAkFeAaCy@uGiDeKiH{GuDmV}PcIwCaM}DqY{QuE_D_IyGoOmIwGqEoO}KqZoRqX_RqpA_z@qe@{ZgIoEgNgF{IqBqN_BsGOeGD}SrAwDTkIJqFa@oFmA_FuBqEyCcEaEkDaFqC{FmCqH{DwMiPij@kEyLkJcSwE_IaGmIgIoJkP_Oau@kl@a_A}t@i[}VwQyNkN}KoLkLu_@o`@cXyXiB_CuAoCkBcHyIqv@yIiw@i@sEmB_OoBgHcAeCuFeJsGiGqJcFoa@uRge@iUwb@mXaMcIyEoDqDmDqHcKsFkKmEiHyEmFqE}DuJaGgCoA_HuBiQkEk^cJim@qOoc@aO}HoCyOyGgHkCmHuBuL{BaMoByKeD_T_IaGcCkE{BuPwG_T_IaL}CoLeEqToJue@iQwm@aUi]iMkMyE{FeCyDqCaBgBoBwCgC{FgEiMoTip@gDeFaDiCcBw@yBk@eDYsCHyG`AwRlD_XvEsEf@iCGqDe@oBo@gCqAgCoBaVkRoA_A{IsGaHyCoD}@gGs@{WuAgTiA_N{@mMuBu]eI}_@{I_IwByCuAmEeDcEmFsBoEoB{G_BqIwEaWw@sCmDoHoCiDmCaCwE_CuIkC{E_B_D{AqPwJem@g^q|Aa~@iNiI_LaG}UkNeIyEmCqAoCs@oBMkDPi`@bGob@xGoEd@wDCmCi@wBkAgO_Ma^wYqc@{^cKqIiEcDqCgAiDa@gRy@{Fa@}Nq@iGYmXeB{^uC}JeAsOqAc^}B{v@gFeZqAuYgBwm@}DkGmA}EcAwCaAsBkA_B}AsE{EuGcH}BiC_DaGqGiTsBiE_CwCaEoDyI{HeCyB]q@KeAHm@jAyAbAKb@^J\\CjA_CnG_@fBSdCcBbJoCrKkDbJgFnIyAfCeAdFiAtHVnHHjFc@hD[j@k@`@y@HcAG{Af@sAvAu@pBSVY`@kA\\e@D{@HqCTeCJsDSuHuBqA_@oFc@wCFqFFkIi@_Fc@m@GBu@@mEB}FBkG@{I?sQ?mAo@?g@tBKFY_@uAFEm@m@FMoAOcB_@kD_AaGs@eFqAsQ';

// chennai
const newPoints =
    "o_lnAokvhN\\CJu@j@?AGLsAg@KAAAAZyEa@ECE?E?[XwCgB@_DF?UxA?|CE|EBdDJbAHfBLLu@PgC@q@@sFFe@AoIKoO@wB?a@EeEEiEAiDBwAB]f@uE@}FK_E?aBAmHCgAIu@[mAs@qAKM_@_@m@e@mB{@_@Km@Ge@CqEAeACuAA}EAoSUmBKk@KkAa@iAo@}CeBwC_B}AeAy@g@[]k@e@gBaBoAsA_@We@S?]DMLM|FZLX^fD@h@GLIJGDSDgA_A{B{BYYc@UQGAUBMPUnGXpBDqBECZ^fD@h@GLIJGDSDgA_A{B{BYYc@UQGAUBMPU|FZKeBQkC?m@bAmF~Cx@FBGC_Dy@TmBCkAUaCK_@Ye@cCeDwAkBqBoC{@t@aDnC}BrBw@x@s@u@ECOGQIh@_CgA{@zAoAp@q@v@s@xCyBSW{@qAa@m@qIeMk@aA}BgCSK{E_BDQfBh@vBt@\\PnBbCJPEJKM}BgCSK{E_B}FsBk@UvA{Cp@_Bt@Jv@\\w@]u@Kq@~AwAzCeAa@{DiABMzDjAfA`@EJeAa@{DiABMRyALaAPqAL_AHeCBk@Cj@IdC_@pCa@zCCLUOECkDu@kAUa@K@Q";
const newPointss = "etonA_~}hNBMNiABOHk@BUFa@D_@@E@I@ODQBW@E@e@@G@e@Bq@@]@M";
