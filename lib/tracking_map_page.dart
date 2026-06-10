import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الميكانيكي'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .doc(widget.mechanicId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text('الطلب غير موجود'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final lat = data['mechanicLatitude'];
          final lng = data['mechanicLongitude'];

          if (lat == null || lng == null) {
            return const Center(
              child: Text('لم يتم تحديد موقع الميكانيكي بعد'),
            );
          }

          final mechanicPosition = LatLng(
            (lat as num).toDouble(),
            (lng as num).toDouble(),
          );

          mapController?.animateCamera(
            CameraUpdate.newLatLng(mechanicPosition),
          );

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: mechanicPosition,
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId('mechanic_location'),
                position: mechanicPosition,
                infoWindow: const InfoWindow(
                  title: 'موقع الميكانيكي',
                ),
              ),
            },
            onMapCreated: (controller) {
              mapController = controller;
            },
          );
        },
      ),
    );
  }
}