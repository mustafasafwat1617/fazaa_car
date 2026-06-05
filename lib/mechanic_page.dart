import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class MechanicPage extends StatelessWidget {
  const MechanicPage({super.key});

  @override
  Widget build(BuildContext context) {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String serviceType = 'ميكانيكي';
    return Scaffold(
      appBar: AppBar(
        title: const Text('الميكانيكي'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(

              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الميكانيكي',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'التخصص',
                border: OutlineInputBorder(),
              ),
              value: serviceType,
              items: const [
                DropdownMenuItem(value: 'ميكانيكي', child: Text('ميكانيكي')),
                DropdownMenuItem(value: 'كهربائي سيارات', child: Text('كهربائي سيارات')),
                DropdownMenuItem(value: 'بنچري', child: Text('بنچري')),
                DropdownMenuItem(value: 'تبديل بطاريات', child: Text('تبديل بطاريات')),
              ],
              onChanged: (value) {
                serviceType = value!;
              },
            ),

            SizedBox(height: 20),

            ElevatedButton(
            onPressed: () async {
            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );
              await
              FirebaseFirestore.instance.collection('mechanics').add({
                'name': nameController.text,
                'phone': phoneController.text,
                'specialty': serviceType,
                'latitude': position.latitude,
                'longitude': position.longitude,
                'createdAt': FieldValue.serverTimestamp(),
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تسجيل مقدم الخدمة بنجاح'),
                ),
              );
            },
              child: const Text('تسجيل'),
            ),
          ],
        ),
      ),
    );
  }
}