import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

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

          final mechanicLat = data['mechanicLatitude'];
          final mechanicLng = data['mechanicLongitude'];
          final customerLat = data['latitude'];
          final customerLng = data['longitude'];

          if (mechanicLat == null || mechanicLng == null) {
            return const Center(
              child: Text('لم يتم تحديد موقع الميكانيكي بعد'),
            );
          }

          final mechanicPosition = LatLng(
            (mechanicLat as num).toDouble(),
            (mechanicLng as num).toDouble(),
          );





          LatLng? customerPosition;
          double? distanceKm;

          if (customerLat != null && customerLng != null) {
            customerPosition = LatLng(
              (customerLat as num).toDouble(),
              (customerLng as num).toDouble(),
            );

            distanceKm = Geolocator.distanceBetween(
                  customerPosition.latitude,
                  customerPosition.longitude,
                  mechanicPosition.latitude,
                  mechanicPosition.longitude,
                ) /
                1000;
          }

          mapController?.animateCamera(
            CameraUpdate.newLatLng(mechanicPosition),
          );

          final markers = <Marker>{
            Marker(
              markerId: const MarkerId('mechanic_location'),
              position: mechanicPosition,
              infoWindow: const InfoWindow(
                title: 'موقع الميكانيكي',
              ),
            ),
          };

          if (customerPosition != null) {
            markers.add(
              Marker(
                markerId: const MarkerId('customer_location'),
                position: customerPosition,
                infoWindow: const InfoWindow(
                  title: 'موقع الزبون',
                ),
              ),
            );
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: mechanicPosition,
                  zoom: 16,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: markers,
                polylines: customerPosition == null
                    ? {}
                    : {
                        Polyline(
                          polylineId: const PolylineId('route'),
                          color: Colors.blue,
                          width: 5,
                          points: [
                            mechanicPosition,
                            customerPosition,
                          ],
                        ),
                      },
                onMapCreated: (controller) {
                  mapController = controller;
                },
              ),

              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      distanceKm == null
                          ? '🚗 الميكانيكي متجه إليك'
                          : '🚗 الميكانيكي متجه إليك\n📍 يبعد عنك ${distanceKm.toStringAsFixed(2)} كم',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}