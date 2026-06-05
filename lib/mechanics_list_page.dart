import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MechanicsListPage extends StatelessWidget {
  const MechanicsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مقدمو الخدمة'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('mechanics')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final mechanics = snapshot.data!.docs;

          return ListView.builder(
            itemCount: mechanics.length,
            itemBuilder: (context, index) {
              final data = mechanics[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.build),
                  title: Text(data['name'] ?? 'بدون اسم'),
                  subtitle: Text(
                    '${data['specialty'] ?? 'بدون تخصص'} - ${data['phone'] ?? 'بدون رقم'}',
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