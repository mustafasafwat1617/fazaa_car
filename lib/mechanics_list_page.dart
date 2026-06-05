import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MechanicsListPage extends StatefulWidget {
  const MechanicsListPage({super.key});

  @override
  State<MechanicsListPage> createState() => _MechanicsListPageState();
}

class _MechanicsListPageState extends State<MechanicsListPage> {
  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مقدمو الخدمة'),
      ),
      body: FutureBuilder<Position>(
        future: getCurrentLocation(),
        builder: (context, locationSnapshot) {
          if (!locationSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userPosition = locationSnapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('mechanics')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final mechanics = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                double distance = 999999;

                if (data['latitude'] != null && data['longitude'] != null) {
                  distance = Geolocator.distanceBetween(
                    userPosition.latitude,
                    userPosition.longitude,
                    data['latitude'],
                    data['longitude'],
                  ) / 1000;
                }

                return {
                  'data': data,
                  'distance': distance,
                };
              }).toList();

              mechanics.sort(
                (a, b) => (a['distance'] as double)
                    .compareTo(b['distance'] as double),
              );

              return ListView.builder(
                itemCount: mechanics.length,
                itemBuilder: (context, index) {
                  final data =
                      mechanics[index]['data'] as Map<String, dynamic>;
                  final distance = mechanics[index]['distance'] as double;

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading: const Icon(Icons.build),
                      title: Text(data['name'] ?? 'بدون اسم'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${data['specialty'] ?? 'بدون تخصص'} - ${data['phone'] ?? 'بدون رقم'}'),
                          Text(
                            distance == 999999
                                ? 'الموقع غير متوفر'
                                : 'يبعد عنك: ${distance.toStringAsFixed(2)} كم',
                          ),
                          const SizedBox(height: 8),

                          ElevatedButton.icon(
                            icon: const Icon(Icons.location_on),
                            label: const Text('فتح الموقع'),
                            onPressed: () async {
                              final lat = data['latitude'];
                              final lng = data['longitude'];

                              if (lat == null || lng == null) return;

                              final url = Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
                              );

                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            },
                          ),

                          const SizedBox(height: 8),

                          ElevatedButton.icon(
                            icon: const Icon(Icons.phone),
                            label: const Text('اتصال'),
                            onPressed: () async {
                              final phone = data['phone'] ?? '';
                              final url = Uri.parse('tel:$phone');
                              await launchUrl(url);
                            },
                          ),

                          const SizedBox(height: 8),

                          ElevatedButton.icon(
                            icon: const FaIcon(
                              FontAwesomeIcons.whatsapp,
                              color: Colors.green,
                            ),
                            label: const Text('واتساب'),
                            onPressed: () async {
                              String phone = data['phone'] ?? '';

                              phone = phone.replaceAll(' ', '');

                              if (phone.startsWith('0')) {
                                phone = '964${phone.substring(1)}';
                              }

                              final url = Uri.parse('https://wa.me/$phone');

                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
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
          );
        },
      ),
    );
  }
}