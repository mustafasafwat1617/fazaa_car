import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'orders_page.dart';

class RequestHelpPage extends StatefulWidget {
  const RequestHelpPage({super.key});

  @override
  State<RequestHelpPage> createState() => _RequestHelpPageState();
}

class _RequestHelpPageState extends State<RequestHelpPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final problemController = TextEditingController();
String serviceType = 'ميكانيكي';
  String carType = 'سيارة بنزين';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب فزعة'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'املأ معلومات الطلب',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسمك',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: carType,
              decoration: const InputDecoration(
                labelText: 'نوع السيارة',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'سيارة بنزين', child: Text('سيارة بنزين')),
                DropdownMenuItem(value: 'سيارة ديزل', child: Text('سيارة ديزل')),
                DropdownMenuItem(value: 'هايبرد', child: Text('هايبرد')),
                DropdownMenuItem(value: 'كهربائية', child: Text('كهربائية')),
              ],
              onChanged: (value) {
                setState(() {
                  carType = value!;
                });
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: serviceType,
              decoration: const InputDecoration(
                labelText: 'نوع الخدمة',
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
                DropdownMenuItem(
                  value: 'سحب سيارات (كرين)',
                  child: Text('سحب سيارات (كرين)'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  serviceType = value!;
                });
              },
            ),

            const SizedBox(height: 15),
            TextField(
              controller: problemController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'وصف العطل',
                hintText: 'مثلاً: السيارة لا تشتغل، بطارية، بنجر، حرارة...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
SizedBox(
  height: 55,
  child: ElevatedButton.icon(
           onPressed: () async {
             await FirebaseFirestore.instance.collection('requests').add({
               'customerName': nameController.text,
               'phone': phoneController.text,
               'carType': carType,
               'serviceType': serviceType,
               'problem': problemController.text,
               'status': 'جديد',
               'createdAt': FieldValue.serverTimestamp(),
             });

             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(
                 content: Text('تم إرسال طلب الفزعة بنجاح'),
               ),
             );

             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => OrdersPage(
                   name: nameController.text,
                   phone: phoneController.text,
                   carType: carType,
                   serviceType: serviceType,
                   problem: problemController.text,
                 ),
               ),
             );
           },
           icon: const Icon(Icons.send),
           label: const Text(
           'إرسال الطلب',
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
