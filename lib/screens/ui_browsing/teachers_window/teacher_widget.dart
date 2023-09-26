import 'package:flutter/material.dart';

import '../../database/mydb.dart';

class TeacherItemWidget extends StatelessWidget {
  final Map<String, dynamic> teacherData;
  final List<Map<String, dynamic>> classes;
  final ValueChanged<int?> onClassChanged;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TeacherItemWidget({
    Key? key,
    required this.teacherData,
    required this.classes,
    required this.onClassChanged,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int selectedClassId = teacherData['te_class'];

    return Card(
      child: ListTile(
        title: Text(
          "${teacherData['te_name']}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String?>(
              future: _getClassName(selectedClassId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("جاري التحميل...");
                } else if (snapshot.hasError) {
                  return const Text("خطأ");
                } else {
                  final className = snapshot.data ?? "غير معروف";
                  return Text(
                    "الصف: $className",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                }
              },
            ),
            Text(
              "الراتب: ${teacherData['te_salary']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
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
      return null; // Handle the case where class name is not found
    }
  }
}
