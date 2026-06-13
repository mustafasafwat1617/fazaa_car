import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProvidersPage extends StatelessWidget {
  const AdminProvidersPage({super.key});

  Future<void> approveProvider(DocumentSnapshot doc) async {
    await doc.reference.update({
      'approved': true,
    });
  }

  Future<void> rejectProvider(DocumentSnapshot doc) async {
    await doc.reference.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('موافقة مقدمي الخدمة'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mechanics')
            .where('approved', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final providers = snapshot.data!.docs;

          if (providers.isEmpty) {
            return const Center(
              child: Text('لا توجد طلبات موافقة حالياً'),
            );
          }

          return ListView.builder(
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final doc = providers[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('الهاتف: ${data['phone'] ?? ''}'),
                      Text('التخصص: ${data['specialty'] ?? ''}'),
                      Text('هاتف الحساب: ${data['userPhone'] ?? ''}'),
                      Text('متاح: ${data['available'] == true ? 'نعم' : 'لا'}'),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text('قبول'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                await approveProvider(doc);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم قبول مقدم الخدمة'),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.close),
                              label: const Text('رفض'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                await rejectProvider(doc);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم رفض مقدم الخدمة'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
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