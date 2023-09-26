// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:rahaf_project/screens/database/mydb.dart';
import 'students_widets.dart' as student_window; // Import the new file

// Constants
const String tableName = "students";
const String columnId = "st_id";
const String columnName = "st_name";
const String columnClassId = "st_class_id"; // Updated column name
const String columnResponsible = "st_responsible";
const String columnMobile = "st_mobile";
const String columnPayment = "st_payment";

class StudentWindow extends StatefulWidget {
  const StudentWindow({Key? key}) : super(key: key);

  @override
  State<StudentWindow> createState() => _StudentWindowState();
}

class _StudentWindowState extends State<StudentWindow> {
  late SqlDb sqlDB;
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> classes = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController responsibleController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController paymentController = TextEditingController();
  int? selectedClassId; // Updated variable
  int? editingStudentID;

  @override
  void initState() {
    super.initState();
    sqlDB = SqlDb();
    _loadData();
  }

  _loadData() async {
    classes = await sqlDB.readData("SELECT cl_id, cl_name FROM classes");
    students =
        await sqlDB.readData("SELECT * FROM $tableName ORDER BY $columnId ASC");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("بيانات الطلاب"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showStudentDialog();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final studentData = students[index];
          return student_window.StudentItemWidget(
            studentData: studentData,
            onDelete: () => _deleteStudent(studentData[columnId]),
            onEdit: () => _showStudentDialog(studentData[columnId]),
          );
        },
      ),
    );
  }

  Future<void> _showStudentDialog([int? studentID]) async {
    editingStudentID = studentID;
    if (editingStudentID != null) {
      final existingStudent =
          students.firstWhere((s) => s[columnId] == editingStudentID);
      nameController.text = existingStudent[columnName];
      selectedClassId = existingStudent[columnClassId]; // Updated assignment
      responsibleController.text = existingStudent[columnResponsible];
      mobileController.text = existingStudent[columnMobile];
      paymentController.text = existingStudent[columnPayment].toString();
    } else {
      nameController.clear();
      selectedClassId = null; // Updated assignment
      responsibleController.clear();
      mobileController.clear();
      paymentController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(editingStudentID != null
              ? "تعديل بيانات الطالب"
              : "إضافة بيانات الطالب"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "اسم الطالب"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يجب إدخال اسم الطالب';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<int>(
                  // Updated DropdownButtonFormField
                  decoration: const InputDecoration(hintText: "الصف الدراسي"),
                  value: selectedClassId,
                  items: classes.map<DropdownMenuItem<int>>((classData) {
                    final classId = classData['cl_id'];
                    final className = classData['cl_name'];
                    return DropdownMenuItem<int>(
                      value: classId,
                      child: Text(className),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedClassId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'يجب إختيار الصف الدراسي';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: responsibleController,
                  decoration: const InputDecoration(hintText: "المسؤول"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يجب إدخال اسم المسؤول';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: mobileController,
                  decoration: const InputDecoration(hintText: "رقم الجوال"),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يجب إدخال رقم الجوال';
                    }
                    return null;
                  },
                ),
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
          ),
          actions: [
            TextButton(
              child: const Text("رجوع"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text("حفظ"),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newName = nameController.text;
                  final newClassId = selectedClassId;
                  final newResponsible = responsibleController.text;
                  final newMobile = mobileController.text;
                  final newPayment = int.parse(paymentController.text);

                  if (editingStudentID != null) {
                    // Update existing student
                    final sql = '''
                      UPDATE $tableName SET
                      $columnName = '$newName',
                      $columnClassId = $newClassId,
                      $columnResponsible = '$newResponsible',
                      $columnMobile = '$newMobile',
                      $columnPayment = $newPayment
                      WHERE $columnId = $editingStudentID
                    ''';
                    await sqlDB.updateData(sql);
                  } else {
                    // Insert new student
                    final sql = '''
                      INSERT INTO $tableName ($columnName, $columnClassId, $columnResponsible, $columnMobile, $columnPayment)
                      VALUES ('$newName', $newClassId, '$newResponsible', '$newMobile', $newPayment)
                    ''';
                    await sqlDB.updateData(sql);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حفظ البيانات بنجاح')));
                  Navigator.pop(context);
                  _loadData();
                }
              },
            )
          ],
        );
      },
    );
  }

  _deleteStudent(int studentID) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تأكيد الحذف"),
          content: const Text("هل أنت متأكد من رغبتك في حذف هذا الطالب؟"),
          actions: [
            TextButton(
              child: const Text("لا"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("نعم"),
              onPressed: () async {
                Navigator.of(context).pop();
                final sql =
                    'DELETE FROM $tableName WHERE $columnId = $studentID';
                final response = await sqlDB.deleteData(sql);
                if (response > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('تم حذف البيانات بنجاح'),
                  ));
                  _loadData();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
