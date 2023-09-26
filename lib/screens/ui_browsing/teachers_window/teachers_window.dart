// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../database/mydb.dart';
import 'teacher_widget.dart';

class TeachersWindow extends StatefulWidget {
  const TeachersWindow({super.key});

  @override
  _TeachersWindowState createState() => _TeachersWindowState();
}

class _TeachersWindowState extends State<TeachersWindow> {
  late SqlDb sqlDB;
  List<Map<String, dynamic>> teachers = [];
  List<Map<String, dynamic>> classes = []; // Add this list
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  int? selectedClassId; // Updated variable
  TextEditingController salaryController = TextEditingController();
  int? editingTeacherID;

  @override
  void initState() {
    super.initState();
    sqlDB = SqlDb();
    _loadData();
  }

  _loadData() async {
    teachers =
        await sqlDB.readData("SELECT * FROM teachers ORDER BY te_id ASC");
    classes = await sqlDB
        .readData("SELECT cl_id, cl_name FROM classes"); // Load classes data
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("بيانات المعلمين"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTeacherDialog();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: teachers.length,
        itemBuilder: (context, index) {
          final teacherData = teachers[index];
          return TeacherItemWidget(
            teacherData: teacherData,
            classes: classes, // Pass the classes data
            onClassChanged: (classId) {
              _updateTeacherClass(teacherData['te_id'], classId);
            },
            onDelete: () => _deleteTeacher(teacherData['te_id']),
            onEdit: () => _showTeacherDialog(teacherData['te_id']),
          );
        },
      ),
    );
  }

  Future<void> _showTeacherDialog([int? teacherID]) async {
    editingTeacherID = teacherID;
    if (editingTeacherID != null) {
      final existingTeacher =
          teachers.firstWhere((t) => t['te_id'] == editingTeacherID);
      nameController.text = existingTeacher['te_name'];
      selectedClassId = existingTeacher['te_class'];
      salaryController.text = existingTeacher['te_salary'].toString();
    } else {
      nameController.clear();
      selectedClassId = null;
      salaryController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            editingTeacherID != null
                ? "تعديل بيانات المعلم"
                : "إضافة معلم جديد",
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "اسم المعلم"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يجب إدخال اسم المعلم';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<int>(
                  value: selectedClassId,
                  items: classes.map<DropdownMenuItem<int>>((classData) {
                    final classId = classData['cl_id'];
                    final className = classData['cl_name'];
                    return DropdownMenuItem<int>(
                      value: classId,
                      child: Text(className),
                    );
                  }).toList(),
                  onChanged: (classId) {
                    setState(() {
                      selectedClassId = classId;
                    });
                  },
                ),
                TextFormField(
                  controller: salaryController,
                  decoration: const InputDecoration(hintText: "الراتب"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يجب إدخال الراتب';
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
                  final newClass = selectedClassId;
                  final newSalary = int.parse(salaryController.text);

                  if (editingTeacherID != null) {
                    final sql = '''
                      UPDATE teachers SET
                      te_name = '$newName',
                      te_class = $newClass,
                      te_salary = $newSalary
                      WHERE te_id = $editingTeacherID
                    ''';
                    await sqlDB.updateData(sql);
                  } else {
                    final sql = '''
                      INSERT INTO teachers (te_name, te_class, te_salary)
                      VALUES ('$newName', $newClass, $newSalary)
                    ''';
                    await sqlDB.insertData(sql);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ البيانات بنجاح')),
                  );
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

  _deleteTeacher(int teacherID) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تأكيد الحذف"),
          content: const Text("هل أنت متأكد من رغبتك في حذف هذا المعلم؟"),
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
                final sql = 'DELETE FROM teachers WHERE te_id = $teacherID';
                final response = await sqlDB.deleteData(sql);
                if (response > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف البيانات بنجاح'),
                    ),
                  );
                  _loadData();
                }
              },
            ),
          ],
        );
      },
    );
  }

  _updateTeacherClass(int teacherID, int? classId) async {
    if (classId != null) {
      final sql =
          'UPDATE teachers SET te_class = $classId WHERE te_id = $teacherID';
      await sqlDB.updateData(sql);
    }
  }
}
