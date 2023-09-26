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
            previousValue + studentData[student_window.columnPayment]);
  }

  _showEditPaymentDialog(int studentID, double currentPayment) {
    final TextEditingController paymentController =
        TextEditingController(text: currentPayment.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تعديل المبلغ المدفوع"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: paymentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "المبلغ المدفوع",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المبلغ المدفوع';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("إلغاء"),
            ),
            TextButton(
              onPressed: () async {
                final newPayment = double.tryParse(paymentController.text);
                if (newPayment != null) {
                  final sql = '''
                    UPDATE ${student_window.tableName}
                    SET ${student_window.columnPayment} = $newPayment
                    WHERE ${student_window.columnId} = $studentID
                  ''';
                  await sqlDB.updateData(sql);
                  _loadPaidStudents();
                  Navigator.of(context).pop();
                }
              },
              child: const Text("حفظ"),
            ),
          ],
        );
      },
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
          final classCost = studentData[classes_window.columnCost];
          final paidAmount = studentData[student_window.columnPayment];
          final studentID = studentData[student_window.columnId];

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
                  IconButton(
                    onPressed: () {
                      _showEditPaymentDialog(studentID, paidAmount);
                    },
                    icon: const Icon(Icons.edit),
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
