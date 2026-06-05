import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'requests_list_page.dart';
import 'mechanics_list_page.dart';
import 'mechanic_page.dart';
import 'orders_page.dart';
import 'request_help_page.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const FazaaCarApp());
}

class FazaaCarApp extends StatelessWidget {
  const FazaaCarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'فزعة كار',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فزعة كار'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.car_repair, size: 110, color: Colors.green),
              const SizedBox(height: 25),
              const Text(
                'مرحبا بك في فزعة كار',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RequestHelpPage(),
                    ),
                  );
                },
                child: const Text(
                  'طلب فزعة',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MechanicPage(),
                    ),
                  );
                },
                child: const Text(
                  'أنا ميكانيكي',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MechanicsListPage(),
                    ),
                  );
                },
                child: const Text(
                  'عرض مقدمي الخدمة',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),

                        const SizedBox(height: 15),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RequestsListPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'طلبات الفزعة',
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        }






