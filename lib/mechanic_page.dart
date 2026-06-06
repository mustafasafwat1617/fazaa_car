import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MechanicPage extends StatefulWidget {
  const MechanicPage({super.key});

  @override
  State<MechanicPage> createState() => _MechanicPageState();
}

class _MechanicPageState extends State<MechanicPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  String serviceType = 'ميكانيكي';
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('خدمة الموقع غير مفعلة');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('لم يتم السماح بالموقع');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> registerMechanic() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال الاسم ورقم الهاتف'),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      Position position = await getCurrentLocation();

      await FirebaseFirestore.instance.collection('mechanics').add({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'userPhone': FirebaseAuth.instance.currentUser?.phoneNumber,
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'specialty': serviceType,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل مقدم الخدمة بنجاح'),
        ),
      );

      nameController.clear();
      phoneController.clear();

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب السماح بالوصول للموقع أولاً'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أنا ميكانيكي'),
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

            const SizedBox(height: 20),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: serviceType,
              decoration: const InputDecoration(
                labelText: 'التخصص',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'ميكانيكي',
                  child: Text('ميكانيكي'),
                ),
                DropdownMenuItem(
                  value: 'كهربائي سيارات',
                  child: Text('كهربائي سيارات'),
                ),
                DropdownMenuItem(
                  value: 'بنجري',
                  child: Text('بنجري'),
                ),
                DropdownMenuItem(
                  value: 'تبديل بطاريات',
                  child: Text('تبديل بطاريات'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    serviceType = value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : registerMechanic,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'تسجيل',
                        style: TextStyle(fontSize: 20),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}