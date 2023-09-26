// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:rahaf_project/screens/database/mydb.dart';
import '../../classes_window/classes_window.dart' as classes_window;
import '../../students_window/student_window.dart' as student_window;

class PaidFeesWindow extends StatefulWidget {
  const PaidFeesWindow({Key? key}) : super(key: key);

  @override
  State<PaidFeesWindow> createState() => _PaidFeesWindowState();
}

class _PaidFeesWindowState extends State<PaidFeesWindow> {
  late SqlDb sqlDB;
  List<Map<String, dynamic>> paidStudents = [];
  double totalPaidAmount = 0.0;

  @override
  void initState() {
    super.initState();
    sqlDB = SqlDb();
    _loadPaidStudents();
  }

  _loadPaidStudents() async {
    // Query to fetch students who have paid the fees successfully
    const sql = '''
      SELECT students.${student_window.columnId}, students.${student_window.columnName}, students.${student_window.columnClassId}, classes.${classes_window.columnCost}, students.${student_window.columnPayment}
      FROM ${student_window.tableName}
      JOIN classes ON students.${student_window.columnClassId} = classes.${classes_window.columnId}
      WHERE students.${student_window.columnPayment} >= classes.${classes_window.columnCost}
    ''';

    paidStudents = await sqlDB.readData(sql);
    _calculateTotalPaidAmount();
    setState(() {});
  }

  _calculateTotalPaidAmount() {
    totalPaidAmount = paidStudents.fold<double>(
      0.0,
      (previousValue, studentData) =>
          previousValue + (studentData[student_window.columnPayment] as double),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("قائمة الطلاب الذين دفعوا الرسوم بنجاح"),
      ),
      body: ListView.builder(
        itemCount: paidStudents.length,
        itemBuilder: (context, index) {
          final studentData = paidStudents[index];
          final studentName = studentData[student_window.columnName];
          final className = studentData[student_window.columnClassId];
          final paidAmount = studentData[student_window.columnPayment];

          return Card(
            child: ListTile(
              title: Text(
                "$studentName",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text("الصف: $className"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "الرسوم المدفوعة: ${paidAmount.toStringAsFixed(2)} ل.س",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "إجمالي المبلغ المدفوع: ${totalPaidAmount.toStringAsFixed(2)} ل.س",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
