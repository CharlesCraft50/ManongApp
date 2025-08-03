import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:manong_application/main.dart';

Future<Position?> getCurrentLocation(BuildContext context) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: Text('Location Disabled'),
        content: Text('Please enable location services to use this feauture.'),
        actions: [
          TextButton(onPressed: () async { 
            Navigator.of(context).pop();
            await Geolocator.openLocationSettings();
            await Future.delayed(Duration(seconds: 2));
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }, child: Text('Open Settings')),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
        ],
      ),
    );

    return null;
  }

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied');
  }

  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}