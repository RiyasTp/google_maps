import 'dart:developer';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;
import 'package:turf/turf.dart';

class PolyLineUtils {
  String encodePath(List<LatLng> path) {
    if (path.isEmpty) {
      return '';
    }

    StringBuffer encodedString = StringBuffer();
    int prevLat = 0;
    int prevLng = 0;

    for (var point in path) {
      final lat = _encodeValue((point.latitude * 1e5).round() - prevLat);
      final lng = _encodeValue((point.longitude * 1e5).round() - prevLng);

      prevLat = (point.latitude * 1e5).round();
      prevLng = (point.longitude * 1e5).round();

      encodedString.write(lat);
      encodedString.write(lng);
    }

    return encodedString.toString();
  }

  String _encodeValue(int value) {
    value = value < 0 ? ~(value << 1) : (value << 1);
    StringBuffer encoded = StringBuffer();
    while (value >= 0x20) {
      encoded.write(String.fromCharCode((0x20 | (value & 0x1f)) + 63));
      value >>= 5;
    }
    encoded.write(String.fromCharCode(value + 63));
    return encoded.toString();
  }

  List getNearestPointOnLine(
    List<LatLng> path,
    LatLng position,
  ) {
    var lineCoords = path.map((e) => Position.of([e.latitude, e.longitude]));
    var line = LineString(coordinates: [
      ...lineCoords,
    ]);
    var pt = Point(
        coordinates: Position.of([position.latitude, position.longitude]));
    var result = nearestPointOnLine(line, pt, Unit.meters);
    log('result sdf ${result.properties}');

    return [
      result.properties?['dist'] ?? 1000,
      result.properties?['index'] ?? -1
    ];
  }

  Future<String> getDirections(LatLng orginLatLng) async {
    try {
      const YOUR_API_KEY = 'AIzaSyAV9nmFBGBHAJ8OsNg1XhGNmoftJXBdyqQ delete';
      const baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';

      // const orginLatLng = LatLng(13.0102061,
      //     80.2373687);
      // https://www.google.co.in/maps/place/IIT+Madras+Main+Gate/@13.0102061,80.2373687,16.43z/
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
      final destStr =
          '${destinationLatLng.latitude},${destinationLatLng.longitude}';

      final url =
          '$baseUrl?destination=$destStr&origin=$originStr&waypoints=$stops&key=$YOUR_API_KEY';

      var response = await Dio().get(url);

      return response.data['routes'][0]['overview_polyline'].toString();
    } catch (e) {
      e;
      return '';
    }
  }

  List<LatLng> getPolyPoints(String newPoints) {
    var polylineCoordinates = <LatLng>[];
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> lines = polylinePoints.decodePolyline(newPoints);
      if (lines.isNotEmpty) {
        for (var point in lines) {
          polylineCoordinates.add(
            LatLng(point.latitude, point.longitude),
          );
        }
      }
    } finally {}
    return polylineCoordinates;
  }

  bool isLocationOnEdge(LatLng point, List<LatLng> points,
      {double tolerance = 50.0}) {
    return toolkit.PolygonUtil.isLocationOnPath(
      toolkit.LatLng(point.latitude, point.longitude),
      points.map((e) => toolkit.LatLng(e.latitude, e.longitude)).toList(),
      true,
      tolerance: tolerance,
    );
    for (int i = 0; i < points.length - 1; i++) {
      if (isPointNearLineSegment(point, points[i], points[i + 1], tolerance)) {
        return true;
      }
    }
    return false;
  }

  bool isPointNearLineSegment(
      LatLng point, LatLng start, LatLng end, double tolerance) {
    log('fsdfsa $point , $start, $end');
    var d = distanceToLineSegment(point, start, end);
    return d <= tolerance;
  }

  double distanceToLineSegment(LatLng p, LatLng start, LatLng end) {
    var l2 = _haversineDistanceSquared(start, end);
    if (l2 == 0) return _haversineDistance(p, start);
    var t = ((p.longitude - start.longitude) *
                (end.longitude - start.longitude) +
            (p.latitude - start.latitude) * (end.latitude - start.latitude)) /
        l2;
    t = math.max(0, math.min(1, t));
    var projection = LatLng(
      start.latitude + t * (end.latitude - start.latitude),
      start.longitude + t * (end.longitude - start.longitude),
    );
    return _haversineDistance(p, projection);
  }

  double _haversineDistance(LatLng a, LatLng b) {
    final tarvelledDistnace = geolocator.Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
    return tarvelledDistnace;
  }

  double _haversineDistanceSquared(LatLng a, LatLng b) {
    var distance = _haversineDistance(a, b);
    return distance * distance;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  String encodeWayPoints(List<LatLng> waypointList) {
    String data = '';
    for (var point in waypointList) {
      data = '$data%7C${point.latitude}%2C${point.longitude}';
    }
    return data;
  }
}
