import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RequestsListPage extends StatelessWidget {
  const RequestsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات الفزعة'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(
              child: Text('لا توجد طلبات حالياً'),
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
                  title: Text(data['customerName'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${data['serviceType']} - ${data['phone']}'),
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
      ),
    );
  }
}