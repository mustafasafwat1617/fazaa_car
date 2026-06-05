import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersPage extends StatelessWidget {

  final String name;
  final String phone;
  final String carType;
  final String serviceType;
  final String problem;

  const OrdersPage({
    super.key,
    required this.name,
    required this.phone,
    required this.carType,
    required this.serviceType,
    required this.problem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الاسم: $name'),
                SizedBox(height: 10),
                Text('الهاتف: $phone'),
                SizedBox(height: 10),
                Text('نوع السيارة: $carType'),
                SizedBox(height: 10),
                Text('نوع الخدمة: $serviceType'),
                SizedBox(height: 10),
                Text('وصف العطل: $problem'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}