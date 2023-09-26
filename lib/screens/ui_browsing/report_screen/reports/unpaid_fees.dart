// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:rahaf_project/screens/database/mydb.dart';

class UnpaidFeesWindwo extends StatefulWidget {
  const UnpaidFeesWindwo({Key? key}) : super(key: key);

  @override
  _UnpaidFeesWindwoState createState() => _UnpaidFeesWindwoState();
}

class _UnpaidFeesWindwoState extends State<UnpaidFeesWindwo> {
  late SqlDb sqlDB;
  List<Map<String, dynamic>> unpaidStudents = [];

  @override
  void initState() {
    super.initState();
    sqlDB = SqlDb();
    _loadUnpaidStudents();
  }

  _loadUnpaidStudents() async {
    // Fetch students who have not paid the full fee based on class cost
    final query = '''
      SELECT students.*, classes.cl_cost
      FROM students
      INNER JOIN classes ON students.st_class_id = classes.cl_id
      WHERE students.st_payment < classes.cl_cost
    ''';

    unpaidStudents = await sqlDB.readData(query);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the total remaining fees for all students
    int totalRemainingFees = unpaidStudents
        .map<int>((studentData) =>
            (studentData['cl_cost'] - studentData['st_payment']) as int)
        .fold(0, (prev, amount) => prev + amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text("تقرير عن الطلاب غير المدفوعين"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: unpaidStudents.length,
        itemBuilder: (context, index) {
          final studentData = unpaidStudents[index];
          final int remainingFees =
              studentData['cl_cost'] - studentData['st_payment'];
          final int paidAmount = studentData['st_payment'];
          return ListTile(
            onTap: () {
              _editStudentPayment(studentData);
            },
            title: Text(
              "${studentData['st_name']}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              "المبلغ المتبقي: $remainingFees ل.س",
              style: const TextStyle(
                color: Colors.red, // You can customize the color
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "المبلغ المدفوع: $paidAmount ل.س",
              style: const TextStyle(
                color: Colors.green, // You can customize the color
              ),
            ),
          );
        },
      ),
      // Display the total remaining fees
      bottomNavigationBar: ListTile(
        title: const Text(
          "المبلغ الإجمالي المتبقي للطلاب:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("$totalRemainingFees ل.س"),
      ),
    );
  }

  Future<void> _editStudentPayment(Map<String, dynamic> studentData) async {
    final TextEditingController paymentController =
        TextEditingController(text: studentData['st_payment'].toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تعديل المبلغ المدفوع"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "اسم الطالب: ${studentData['st_name']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: paymentController,
                decoration: const InputDecoration(hintText: "المبلغ المدفوع"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يجب إدخال المبلغ المدفوع';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("رجوع"),
            ),
            TextButton(
              onPressed: () async {
                final newPayment = int.parse(paymentController.text.toString());
                final studentID = studentData['st_id'];

                final sql = '''
                  UPDATE students
                  SET st_payment = $newPayment
                  WHERE st_id = $studentID
                ''';

                await sqlDB.updateData(sql);

                // Reload the data to reflect the updated payment
                _loadUnpaidStudents();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث المبلغ المدفوع بنجاح'),
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text("حفظ"),
            ),
          ],
        );
      },
    );
  }
}
