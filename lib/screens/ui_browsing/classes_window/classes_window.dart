// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:rahaf_project/screens/database/mydb.dart';

const String tableName = "classes";
const String columnId = "cl_id";
const String columnName = "cl_name";
const String columnCost = "cl_cost";

class ClassesData extends StatefulWidget {
  const ClassesData({Key? key}) : super(key: key);

  @override
  State<ClassesData> createState() => _ClassesDataState();
}

class _ClassesDataState extends State<ClassesData> {
  late SqlDb sqlDB;
  List<Map<String, dynamic>> classes = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    sqlDB = SqlDb();
    _loadClasses();
  }

  @override
  void dispose() {
    nameController.dispose();
    costController.dispose();
    super.dispose();
  }

  _loadClasses() async {
    classes =
        await sqlDB.readData("SELECT * FROM $tableName ORDER BY $columnId ASC");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("بيانات الصفوف"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addClass,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final classData = classes[index];
          return _buildClassItem(classData);
        },
      ),
    );
  }

  Widget _buildClassItem(Map<String, dynamic> classData) {
    return Card(
      child: ListTile(
        title: Text(
          "${classData[columnName]}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text("${classData[columnCost]} ل.س"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _deleteClass(classData[columnId]);
              },
              icon: const Icon(Icons.delete, color: Colors.black54),
              label: const Text(
                "حذف",
                style: TextStyle(color: Colors.black54),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.redAccent),
              ),
            ),
            const SizedBox(width: 10.0),
            ElevatedButton.icon(
              onPressed: () {
                _editClass(classData[columnId]);
              },
              icon: const Icon(Icons.edit),
              label: const Text("تعديل"),
            ),
          ],
        ),
      ),
    );
  }

  _deleteClass(int classID) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تأكيد الحذف"),
          content: const Text("هل أنت متأكد من رغبتك في حذف هذا الصف؟"),
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
                final sql = '''
                DELETE FROM $tableName WHERE $columnId = $classID
              ''';
                final response = await sqlDB.deleteData(sql);
                if (response > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('تم حذف البيانات بنجاح'),
                  ));
                  _loadClasses();
                }
              },
            ),
          ],
        );
      },
    );
  }

  _editClass(int classID) async {
    final existingClass = classes.firstWhere((c) => c[columnId] == classID);
    final existingName = existingClass[columnName];
    final existingCost = existingClass[columnCost];

    nameController.text = existingName;
    costController.text = existingCost.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تعديل بيانات الصف"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "اسم الصف"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يجب إدخال اسم الصف';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: costController,
                  decoration: const InputDecoration(hintText: "تكلفة الصف"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يجب إدخال تكلفة الصف';
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
                  final newCost = int.parse(costController.text);

                  final sql =
                      "UPDATE $tableName SET $columnName = '$newName', $columnCost = $newCost WHERE $columnId = $classID";

                  await sqlDB.updateData(sql);

                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تعديل البيانات بنجاح')));
                  Navigator.pop(context);
                  _loadClasses();
                }
                nameController.clear();
                costController.clear();
              },
            )
          ],
        );
      },
    );
  }

  _addClass() async {
    nameController.clear();
    costController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("إضافة بيانات الصفوف"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "اسم الصف"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يجب إدخال اسم الصف';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: costController,
                  decoration: const InputDecoration(hintText: "تكلفة الصف"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يجب إدخال تكلفة الصف';
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
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("إضافة"),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newClassName = nameController.text;
                  final newClassCost = int.parse(costController.text);

                  final sql = '''
                    INSERT INTO classes ("cl_name", "cl_cost")
                    VALUES ("${newClassName.trim()}" , "$newClassCost")
                  ''';
                  int response = await sqlDB.updateData(sql);
                  if (response > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('تم إضافة البيانات بنجاح')));
                    Navigator.pop(context);
                    _loadClasses();

                    nameController.clear();
                    costController.clear();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('يبدو أنه حصل خطأ ما، تأكد من البيانات')));
                  }
                }
              },
            )
          ],
        );
      },
    );
  }
}
