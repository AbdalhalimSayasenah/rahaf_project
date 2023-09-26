import 'package:flutter/material.dart';
import '../../database/mydb.dart';
import 'student_window.dart' as student_window;

class StudentItemWidget extends StatelessWidget {
  final Map<String, dynamic> studentData;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const StudentItemWidget({
    Key? key,
    required this.studentData,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          "${studentData[student_window.columnName]}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: FutureBuilder<String?>(
          future: _getClassName(studentData[student_window.columnClassId]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading...");
            } else if (snapshot.hasError || snapshot.data == null) {
              return const Text("Error");
            } else {
              final className = snapshot.data;
              return Text(className ?? "");
            }
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: onDelete,
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
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              label: const Text("تعديل"),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _getClassName(int classId) async {
    final sqlDB = SqlDb();
    final classNameResult = await sqlDB.readData(
      "SELECT cl_name FROM classes WHERE cl_id = $classId",
    );

    if (classNameResult.isNotEmpty) {
      return classNameResult[0]['cl_name'];
    } else {
      return null;
    }
  }
}

class StudentDialog extends StatelessWidget {
  final TextEditingController nameController;
  final int? selectedClassId;
  final TextEditingController responsibleController;
  final TextEditingController mobileController;
  final TextEditingController paymentController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const StudentDialog({
    Key? key,
    required this.nameController,
    required this.selectedClassId,
    required this.responsibleController,
    required this.mobileController,
    required this.paymentController,
    required this.formKey,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("إضافة بيانات الطالب"),
      content: Form(
        key: formKey,
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
            // Implement DropdownButtonFormField for selecting a class
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text("رجوع"),
        ),
        TextButton(
          onPressed: onSave,
          child: const Text("حفظ"),
        )
      ],
    );
  }
}
