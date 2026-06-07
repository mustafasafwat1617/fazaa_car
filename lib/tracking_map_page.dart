import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingMapPage extends StatefulWidget {
  final String mechanicId;

  const TrackingMapPage({
    super.key,
    required this.mechanicId,
  });

  @override
  State<TrackingMapPage> createState() => _TrackingMapPageState();
}

class _TrackingMapPageState extends State<TrackingMapPage> {
  GoogleMapController? mapController;
  LatLng? currentPosition;
  Timer? locationTimer;

  bool isLoading = true;
  String? errorMessage;



  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _startTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          isLoading = false;
          errorMessage = 'يرجى تشغيل GPS';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          isLoading = false;
          errorMessage = 'يرجى السماح بالوصول إلى الموقع';
        });
        return;
      }

      await _updateLocationToFirebase();

      locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        _updateLocationToFirebase();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'حدث خطأ أثناء تشغيل التتبع';
      });
    }
  }

  Future<void> _updateLocationToFirebase() async {
    final position = await Geolocator.getCurrentPosition();

    final latLng = LatLng(position.latitude, position.longitude);

    await FirebaseFirestore.instance
        .collection('mechanic_locations')
        .doc(widget.mechanicId)
        .set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      currentPosition = latLng;
      isLoading = false;
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLng(latLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null || currentPosition == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تتبع الميكانيكي')),
        body: Center(
          child: Text(
            errorMessage ?? 'لم يتم العثور على الموقع',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الميكانيكي'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mechanic_locations')
            .doc(widget.mechanicId)
            .snapshots(),
        builder: (context, snapshot) {
          Set<Marker> markers = {
            Marker(
              markerId: const MarkerId('my_location'),
              position: currentPosition!,
              infoWindow: const InfoWindow(title: 'موقعي الحالي'),
            ),
          };

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;

            final mechanicPosition = LatLng(
              data['latitude'],
              data['longitude'],
            );

            markers.add(
              Marker(
                markerId: const MarkerId('mechanic_location'),
                position: mechanicPosition,
                infoWindow: const InfoWindow(title: 'موقع الميكانيكي'),
              ),
            );
          }

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentPosition!,
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: markers,
            onMapCreated: (controller) {
              mapController = controller;
            },
          );
        },
      ),
    );
  }
}