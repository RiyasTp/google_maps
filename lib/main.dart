import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps/screens/polyline_animation.dart';
import 'package:google_maps/screens/remove_polyline.dart';
import 'package:google_maps/screens/traking_page.dart';
import 'package:google_maps/utils/poly_line_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        floatingActionButton: FloatingActionButton(onPressed: () {
          var points =
              "q{nnA{s}hNsU]~C}OmPwBoIxYtf@{Qyk@qMwS~GcGqJ}BnIyGiBsKlC}DiGaSrDaInJxfB|KjUoWl[pDiXrZ}@uPeTtMs_@Nab@Rb@uCaRaT_T_JeQnLqIiVwM_A_QpGeRaM|Vx_@|YQaAfTjoAtAdpA~Sj_@eGjMiPaCng@|In]uEzZ_DlZaRdDcWkEaL`SoSmMsOiEyIqQeUgD_R}O{JjDkHjQ{EtPuNkCtFw{Bb@rN}BeWqZ~Cc_@sSoHtR}LqNlRqJ{O}PoVtNdFz_@xYjS|W`@cFuVzPrg@yElOgBjHwUwFeSoL}EoJuEqUqQiIsJtO_LfF_PpFgBlLO`QyHpKaNZyB{VcC}JFsL[{UqFsZGmVnBUgP_NgIsKjPd@uNmLaIqA";
          var object = PolylinePoints().decodePolyline(points);

          //  log(object.map((e) =>"(${e.latitude}, ${e.longitude})").toList() .toString());
          final encoded = PolyLineUtils().encodePath(
              object.map((e) => LatLng(e.latitude, e.longitude)).toList());
          log('encoded $encoded');
          var object2 = PolylinePoints().decodePolyline(encoded);
          log('message ad  $object2');
        }),
        body: const MianScreen(),
      ),
    );
  }
}

class MianScreen extends StatelessWidget {
  const MianScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final snackBar = SnackBar(content: Text("Hello, world"));
    return Scaffold(
      key: _scaffoldKey,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderTrackingPage(),
                      ));
                },
                child: const Text('Tracking')),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PolylineAnimationPage(),
                      ));
                },
                child: const Text('animated')),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RemovePolyLineScreen(),
                      ));
                },
                child: const Text('Remove poly'))
          ],
        ),
      ),
    );
  }
}
