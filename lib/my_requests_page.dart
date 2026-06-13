import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'tracking_map_page.dart';

class MyRequestsPage extends StatelessWidget {
  const MyRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(
              child: Text('لا توجد طلبات خاصة بك'),
            );
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['serviceType'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text('السيارة: ${data['carType'] ?? ''}'),
                      Text('العطل: ${data['problem'] ?? ''}'),

                      Text(
                        data['status'] == 'تم القبول'
                            ? '✅ تم القبول'
                            : data['status'] == 'في الطريق'
                            ? '🟢 قيد التنفيذ'
                                : data['status'] == 'تم الإنجاز'
                                    ? '🎉 تم إنجاز الطلب'
                                    : '⏳ بانتظار الميكانيكي',
                        style: TextStyle(
                          color: data['status'] == 'تم القبول' ||
                                  data['status'] == 'في الطريق'
                              ? Colors.green
                              : data['status'] == 'تم الإنجاز'
                                  ? Colors.blue
                                  : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      if (data['acceptedPhone'] != null)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.phone),
                          label: const Text('اتصال بالميكانيكي'),
                          onPressed: () async {
                            final phone = data['acceptedPhone'];
                            final url = Uri.parse('tel:$phone');
                            await launchUrl(url);
                          },
                        ),

                      const SizedBox(height: 8),

                      if (data['acceptedPhone'] != null)
                        ElevatedButton.icon(
                          icon: const FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Colors.green,
                          ),
                          label: const Text('واتساب الميكانيكي'),
                          onPressed: () async {
                            String phone = data['acceptedPhone'] ?? '';

                            phone = phone.replaceAll(' ', '');

                            if (phone.startsWith('+')) {
                              phone = phone.substring(1);
                            }

                            if (phone.startsWith('0')) {
                              phone = '964${phone.substring(1)}';
                            }

                            final message = Uri.encodeComponent(
                              'السلام عليكم، أنا صاحب طلب الفزعة.',
                            );

                            final url = Uri.parse(
                              'https://wa.me/$phone?text=$message',
                            );

                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                        ),

                      const SizedBox(height: 8),

                      if (data['providerName'] != null)
                        Text(
                          '🚗 ${data['providerName']} متجه إليك',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                      const SizedBox(height: 8),

                      if (data['mechanicLatitude'] != null &&
                          data['mechanicLongitude'] != null)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.location_on),
                          label: const Text('تتبع الميكانيكي'),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TrackingMapPage(
                                  mechanicId: requests[index].id,
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 8),


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