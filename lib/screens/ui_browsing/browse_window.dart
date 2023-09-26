import 'package:flutter/material.dart';
import '../database/mydb.dart';
import 'classes_window/classes_window.dart';
import 'report_screen/report_screen.dart';
import 'students_window/student_window.dart';
import 'teachers_window/teachers_window.dart';

class BrowsingWindow extends StatefulWidget {
  const BrowsingWindow({Key? key}) : super(key: key);

  @override
  State<BrowsingWindow> createState() => _BrowsingWindowState();
}

class _BrowsingWindowState extends State<BrowsingWindow> {
  SqlDb sqlDb = SqlDb();

  @override
  void dispose() {
    sqlDb.close(); // Close the database when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تصفح البيانات"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _studentsBrowser,
              icon: const Icon(Icons.people),
              label: const Text("تصفح بيانات الطلاب"),
            ),
            ElevatedButton.icon(
              onPressed: _teachersBrowser,
              icon: const Icon(Icons.how_to_reg_sharp),
              label: const Text("تصفح بيانات المعلمين"),
            ),
            ElevatedButton.icon(
              onPressed: _classesBrowser,
              icon: const Icon(Icons.class_),
              label: const Text("تصفح الصفوف"),
            ),
            ElevatedButton.icon(
              onPressed: _reportBrowser,
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text("التقارير"),
            ),
          ],
        ),
      ),
    );
  }

  void _studentsBrowser() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const StudentWindow()));
  }

  void _teachersBrowser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TeachersWindow()),
    );
  }

  void _classesBrowser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClassesData()),
    );
  }

  void _reportBrowser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportScreen()),
    );
  }
}
