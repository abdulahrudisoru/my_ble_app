import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/bluetooth_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: BluetoothScreen(),
    );
  }
}
