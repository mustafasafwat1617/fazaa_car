import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_providers_page.dart';
import 'completed_requests_page.dart';
import 'approved_providers_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  Future<int> countDocs(
    String collection,
    String field,
    dynamic value,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where(field, isEqualTo: value)
        .get();

    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
      ),
      body: FutureBuilder<List<int>>(
        future: Future.wait([
          countDocs('requests', 'status', 'جديد'),
          countDocs('requests', 'status', 'قيد التنفيذ'),
          countDocs('requests', 'status', 'تم الإنجاز'),
          countDocs('mechanics', 'approved', true),
          countDocs('mechanics', 'rejected', true),
          countDocs('mechanics', 'available', true),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              buildCard(
                'الطلبات الجديدة',
                data[0].toString(),
                Icons.new_releases,
              ),

              buildCard(
                'قيد التنفيذ',
                data[1].toString(),
                Icons.build,
              ),

              buildCard(
                'الطلبات المكتملة',
                data[2].toString(),
                Icons.check_circle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CompletedRequestsPage(),
                    ),
                  );
                },
              ),

              buildCard(
                'المقبولين',
                data[3].toString(),
                Icons.verified,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApprovedProvidersPage()
                    ),
                  );
                },
              ),

              buildCard(
                'المرفوضين',
                data[4].toString(),
                Icons.cancel,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('صفحة المرفوضين قيد الإنشاء'),
                    ),
                  );
                },
              ),

              buildCard(
                'المتاحين حالياً',
                data[5].toString(),
                Icons.location_on,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildCard(
    String title,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          size: 35,
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}