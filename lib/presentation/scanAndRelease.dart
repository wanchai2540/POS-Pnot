import 'package:flutter/material.dart';

class ScanAndRelasePage extends StatefulWidget {
  const ScanAndRelasePage({super.key});

  @override
  State<ScanAndRelasePage> createState() => _ScanAndRelasePageState();
}

class _ScanAndRelasePageState extends State<ScanAndRelasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สแกนพร้อมปล่อยของ'),
      ),
      body: Container(
        child: Text('สแกนพร้อมปล่อยของ'),
      ),
    );
  }
}
