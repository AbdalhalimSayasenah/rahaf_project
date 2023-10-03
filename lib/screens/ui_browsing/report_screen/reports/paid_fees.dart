import 'package:flutter/material.dart';
import 'package:rahaf_project/screens/database/mydb.dart';

class PaidFeesWindow extends StatefulWidget {
  const PaidFeesWindow({Key? key}) : super(key: key);

  @override
  _PaidFeesWindowState createState() => _PaidFeesWindowState();
}

class _PaidFeesWindowState extends State<PaidFeesWindow> {
  late SqlDb sqlDB;
  List<Map<String, dynamic>> paidStudents = [];

  @override
  void initState() {
    super.initState();
    sqlDB = SqlDb();
    _loadPaidStudents();
  }

  Future<void> _loadPaidStudents() async {
    // Fetch students who have paid the full fee based on class cost
    const query = '''
      SELECT students.*, classes.cl_cost
      FROM students
      INNER JOIN classes ON students.st_class_id = classes.cl_id
      WHERE students.st_payment >= classes.cl_cost
    ''';

    final result = await sqlDB.readData(query);

    setState(() {
      paidStudents = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalRemainingFees = paidStudents
        .map<int>((studentData) =>
            (studentData['cl_cost'] - studentData['st_payment']) as int)
        .fold(0, (prev, amount) => prev + amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text("تقرير عن الطلاب المدفوعين بالكامل"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: paidStudents.length,
        itemBuilder: (context, index) {
          final studentData = paidStudents[index];
          final int remainingFees =
              studentData['cl_cost'] - studentData['st_payment'];
          final int paidAmount = studentData['st_payment'];
          return ListTile(
            onTap: () {
              _editStudentPayment(studentData);
            },
            leading: const Icon(Icons.person_2_rounded),
            title: Text(
              "${studentData['st_name']}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              "المبلغ الفائض: ${remainingFees * -1} ل.س",
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "المبلغ المدفوع: $paidAmount ل.س",
              style: const TextStyle(
                color: Colors.green,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "إجمالي المبلغ الفائض: ${totalRemainingFees * -1} ل.س",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
                await _loadPaidStudents(); // Add 'await' here

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
