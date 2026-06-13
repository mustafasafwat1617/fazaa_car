import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class AcceptedRequestsPage extends StatefulWidget {
  const AcceptedRequestsPage({super.key});

  @override
  State<AcceptedRequestsPage> createState() => _AcceptedRequestsPageState();
}

class _AcceptedRequestsPageState extends State<AcceptedRequestsPage> {
  Timer? locationTimer;
  String? activeRequestId;

  Future<Position> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('لم يتم السماح بالموقع');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void startLiveTracking(String requestId) {
    activeRequestId = requestId;

    locationTimer?.cancel();

    locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        try {
          final position = await getCurrentLocation();

          await FirebaseFirestore.instance
              .collection('requests')
              .doc(requestId)
              .update({
            'mechanicLatitude': position.latitude,
            'mechanicLongitude': position.longitude,
            'mechanicLocationUpdatedAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          debugPrint('Live tracking error: $e');
        }
      },
    );
  }

  void stopLiveTracking() {
    locationTimer?.cancel();
    locationTimer = null;
    activeRequestId = null;
  }

  Future<void> openMap(dynamic lat, dynamic lng) async {
    if (lat == null || lng == null) return;

    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> callPhone(String phone) async {
    if (phone.isEmpty) return;
    final url = Uri.parse('tel:$phone');
    await launchUrl(url);
  }

  Future<void> openWhatsApp(String phone) async {
    if (phone.isEmpty) return;

    phone = phone.replaceAll(' ', '');

    if (phone.startsWith('0')) {
      phone = '964${phone.substring(1)}';
    }

    if (phone.startsWith('+')) {
      phone = phone.substring(1);
    }

    final url = Uri.parse('https://wa.me/$phone');

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    stopLiveTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات المقبولة'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('acceptedBy', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == 'تم القبول' ||
                data['status'] == 'في الطريق';
          }).toList();

          if (requests.isEmpty) {
            return const Center(
              child: Text('لا توجد طلبات مقبولة'),
            );
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;
              final requestId = requests[index].id;
              final isTracking = activeRequestId == requestId;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['customerName'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${data['serviceType'] ?? ''} - ${data['phone'] ?? ''}'),
                      Text('السيارة: ${data['carType'] ?? ''}'),
                      Text('العطل: ${data['problem'] ?? ''}'),
                      Text('الحالة: ${data['status'] ?? ''}'),

                      const SizedBox(height: 8),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.location_on),
                        label: const Text('فتح موقع الزبون'),
                        onPressed: () {
                          openMap(data['latitude'], data['longitude']);
                        },
                      ),

                      const SizedBox(height: 8),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.directions_car),
                        label: const Text('أنا في الطريق'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          try {
                            final position = await getCurrentLocation();

                            await requests[index].reference.update({
                              'status': 'في الطريق',
                              'mechanicLatitude': position.latitude,
                              'mechanicLongitude': position.longitude,
                              'mechanicLocationUpdatedAt':
                                  FieldValue.serverTimestamp(),
                            });

                            startLiveTracking(requestId);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم تشغيل التتبع المباشر'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يجب السماح بالوصول للموقع'),
                              ),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 8),

                      if (isTracking)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.stop_circle),
                          label: const Text('إيقاف التتبع'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            stopLiveTracking();

                            setState(() {});

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم إيقاف التتبع'),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 8),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.phone),
                        label: const Text('اتصال'),
                        onPressed: () {
                          callPhone(data['phone'] ?? '');
                        },
                      ),

                      const SizedBox(height: 8),

                      ElevatedButton.icon(
                        icon: const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.green,
                        ),
                        label: const Text('واتساب'),
                        onPressed: () {
                          openWhatsApp(data['phone'] ?? '');
                        },
                      ),

                      const SizedBox(height: 8),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.done_all),
                        label: const Text('إنهاء الطلب'),
                        onPressed: () async {
                          stopLiveTracking();

                          await requests[index].reference.update({
                            'status': 'تم الإنجاز',
                            'completedAt': FieldValue.serverTimestamp(),
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إنهاء الطلب بنجاح'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}