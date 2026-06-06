import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
              final data =
                  requests[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['serviceType'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('السيارة: ${data['carType'] ?? ''}'),
                      Text('العطل: ${data['problem'] ?? ''}'),
                      Text('الحالة: ${data['status'] ?? 'جديد'}'),
                      if (data['acceptedPhone'] != null)
                        Text(
                          'رقم الميكانيكي: ${data['acceptedPhone']}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

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

                              final url = Uri.parse('https://wa.me/$phone?text=$message');

                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                          ),
const SizedBox(height: 8),

ElevatedButton.icon(
  icon: const Icon(Icons.location_on),
  label: const Text('فتح موقع الطلب'),
  onPressed: () async {
    final lat = data['latitude'];
    final lng = data['longitude'];

    if (lat == null || lng == null) return;

    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  },
),
                      Text('الهاتف: ${data['phone'] ?? ''}'),
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