import 'package:flutter/material.dart';
import 'package:google_maps/home_screen.dart';
import 'package:google_maps/traking_page.dart';

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
                        builder: (context) => OrderTrackingPage(),
                      ));
                },
                child: Text('Tracking')),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ));
                },
                child: Text('animated'))
          ],
        ),
      ),
    );
  }
}
