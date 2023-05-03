import 'package:flutter/material.dart';
import 'package:google_maps/screens/polyline_animation.dart';
import 'package:google_maps/screens/traking_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MianScreen(), 
    );
  }
}

class MianScreen extends StatelessWidget {
  const MianScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          
          crossAxisAlignment:  CrossAxisAlignment.center,
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
                child: const Text('animated'))
          ],
        ),
      ),
    );
  }
}