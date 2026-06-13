import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApprovedProvidersPage extends StatelessWidget {
  ApprovedProvidersPage({super.key});

  final providers = FirebaseFirestore.instance
      .collection('mechanics')
      .where('approved', isEqualTo: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المقبولون'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: providers,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('لا يوجد مقدمو خدمة مقبولون'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data =
                  docs[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(
                    Icons.verified,
                    color: Colors.green,
                  ),
                  title: Text(
                    data['name'] ?? 'بدون اسم',
                  ),
                  subtitle: Text(
                    data['phone'] ?? '',
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