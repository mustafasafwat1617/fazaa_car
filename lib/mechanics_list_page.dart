import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MechanicsListPage extends StatefulWidget {
  final String specialty;

  const MechanicsListPage({
    super.key,
    required this.specialty,
  });

  @override
  State<MechanicsListPage> createState() =>
      _MechanicsListPageState();
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
        title: Text(widget.specialty),
      ),
      body: FutureBuilder<Position>(
        future: getCurrentLocation(),
        builder: (context, locationSnapshot) {
        if (locationSnapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_off,
                    size: 70,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'يجب السماح بالوصول للموقع لعرض مقدمي الخدمة',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () async {
                      await Geolocator.openAppSettings();
                    },
                    child: const Text('فتح الإعدادات'),
                  ),
                ],
              ),
            ),
          );
        }
          if (!locationSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userPosition = locationSnapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                        .collection('mechanics')
                        .where('specialty',isEqualTo: widget.specialty)

                          .where('available',isEqualTo: true)
                          .where('approved', isEqualTo: true)

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

              mechanics.sort((a, b) {
                final dataA = a['data'] as Map<String, dynamic>;
                final dataB = b['data'] as Map<String, dynamic>;

                final ratingA = ((dataA['ratingAverage'] ?? 0) as num).toDouble();
                final ratingB = ((dataB['ratingAverage'] ?? 0) as num).toDouble();

                final jobsA = ((dataA['completedJobs'] ?? 0) as num).toInt();
                final jobsB = ((dataB['completedJobs'] ?? 0) as num).toInt();

                final distanceA = a['distance'] as double;
                final distanceB = b['distance'] as double;

                final ratingCompare = ratingB.compareTo(ratingA);
                if (ratingCompare != 0) return ratingCompare;

                final jobsCompare = jobsB.compareTo(jobsA);
                if (jobsCompare != 0) return jobsCompare;

                return distanceA.compareTo(distanceB);
              });

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

                        if (((data['ratingAverage'] ?? 0) as num).toDouble() >= 4.5 &&
                              ((data['completedJobs'] ?? 0) as num).toInt() >= 10)
                            Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '🏆 موثوق',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),










                        Text(
                          '${data['specialty'] ?? 'بدون تخصص'} - ${data['phone'] ?? 'بدون رقم'}',
                        ),

                        Text(
                          '⭐ ${((data['ratingAverage'] ?? 0) as num).toDouble().toStringAsFixed(1)} (${data['ratingCount'] ?? 0} تقييم)',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          '✅ ${data['completedJobs'] ?? 0} خدمة منجزة',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

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