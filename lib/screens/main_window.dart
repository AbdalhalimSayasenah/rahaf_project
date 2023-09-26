import 'package:flutter/material.dart';
import 'ui_browsing/browse_window.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('روضة المروج'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: _gotoDataBrowsingPage,
            icon: const Icon(Icons.search),
            label: const Text('تصفح البيانات'),
          ),
        ),
      ),
    );
  }

  void _gotoDataBrowsingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BrowsingWindow()),
    );
  }
}
