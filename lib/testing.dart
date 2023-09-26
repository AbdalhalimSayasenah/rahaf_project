// import 'package:flutter/material.dart';
// import '../../database/mydb.dart';
//
// class ClassesList extends StatefulWidget {
//   @override
//   _ClassesListState createState() => _ClassesListState();
// }
//
// class _ClassesListState extends State<ClassesList> {
//   late List<Map<String, dynamic>> _classes;
//
//   @override
//   void initState() {
//     super.initState();
//     _classes = [];
//     _loadClasses();
//   }
//
//   Future<void> _loadClasses() async {
//     final sql = "SELECT * FROM classes ORDER BY cl_id ASC";
//     final classes = await SqlDb().readData(sql);
//
//     setState(() {
//       _classes = classes;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("بيانات الصفوف"),
//       ),
//       body: _classes.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//         itemCount: _classes.length,
//         itemBuilder: (context, index) {
//           return _buildClassItem(_classes[index]);
//         },
//       ),
//     );
//   }
//
//   Widget _buildClassItem(Map<String, dynamic> classData) {
//     return Card(
//       child: ListTile(
//         title: Text(classData['cl_name']),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               "${classData['cl_cost']} ل.س",
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.deepPurple,
//               ),
//             ),
//             const SizedBox(width: 10),
//             IconButton(
//               onPressed: () =>
//                   _editClass(classData['cl_id'], classData['cl_cost']),
//               icon: const Icon(Icons.edit),
//             ),
//             IconButton(
//               onPressed: () => _deleteClass(classData['cl_id']),
//               icon: const Icon(Icons.delete),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // EDIT CLASS DATA DIALOG ========
//
//   void _editClass(int classId, int currentCost) {
//     TextEditingController classNameController = TextEditingController();
//     TextEditingController classCostController =
//     TextEditingController(text: currentCost.toString());
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("تعديل بيانات الصف"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: classNameController,
//               decoration: InputDecoration(
//                 hintText: "اسم الصف الجديد",
//               ),
//             ),
//             TextField(
//               controller: classCostController,
//               decoration: InputDecoration(
//                 hintText: "تكلفة الصف الجديدة",
//               ),
//               keyboardType: TextInputType.number,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               "رجوع",
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//           TextButton(
//             onPressed: () async {
//               String newClassName = classNameController.text;
//               int newClassCost =
//                   int.tryParse(classCostController.text) ?? currentCost;
//
//               // Save changes here
//               final sql =
//                   "UPDATE classes SET cl_name = $newClassName, cl_cost = $newClassCost WHERE cl_id = $classId";
//
//               updateData(sql);
//
//               Navigator.pop(context);
//             },
//             child: const Text("حفظ"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Future<void> _updateClassData(
//   //     int classId, String newClassName, int newClassCost) async {
//   //   // Update the class data in the database
//   //   final sql = "UPDATE classes SET cl_name = $newClassName, cl_cost = $newClassCost WHERE cl_id = $classId";
//   //   await SqlDb().execute(sql);
//   //
//   //   // Reload the updated class data
//   //   _loadClasses();
//   // }
//
//   void _deleteClass(int classId) async {
//     // Delete the class from the database
//     // final sql = "DELETE FROM classes WHERE cl_id = $classId";
//     // await SqlDb().execute(sql);
//
//     // Reload the class data
//     _loadClasses();
//   }
// }





//----------------- DATABASE ----------
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class SqlDb {
//   static Database? _db;

//   Future<Database?> get db async {
//     if (_db == null) {
//       _db = await initialDb();
//       return _db;
//     } else {
//       return _db;
//     }
//   }

//   initialDb() async {
//     String databasepath = await getDatabasesPath();
//     String path = join(databasepath, 'wael.db');
//     Database mydb = await openDatabase(path,
//         onCreate: _onCreate, version: 3, onUpgrade: _onUpgrade);
//     return mydb;
//   }

//   _onUpgrade(Database db, int oldversion, int newversion) {
//     print("onUpgrade =====================================");
//   }

//   _onCreate(Database db, int version) async {

//     Batch batch = db.batch();

//     batch.execute('''
//   CREATE TABLE "classes" (
//     "cl_id" INTEGER  NOT NULL PRIMARY KEY  AUTOINCREMENT, 
//     "cl_name" TEXT NOT NULL,
//     "cl_cost" INTEGER NOT NULL
//   )
//  ''');
//     print(" classes table =====================================");

//     // ---------------------------------------------------

//     batch.execute('''
//   CREATE TABLE "teachers" (
//     "te_id" INTEGER  NOT NULL PRIMARY KEY  AUTOINCREMENT, 
//     "te_name" TEXT NOT NULL,
//     "te_class" INTEGER NOT NULL,
//     "te_salary" INTEGER NOT NULL,
    
//     FOREIGN KEY ("te_class") REFERENCES "classes" ("cl_id") 
//                 ON DELETE NO ACTION ON UPDATE NO ACTION
//   )
//  ''');
//     print(" teachers table =====================================");

//     // --------------------------------------------------

//     batch.execute('''
//   CREATE TABLE "students" (
//     "st_id" INTEGER  NOT NULL PRIMARY KEY  AUTOINCREMENT, 
//     "st_name" TEXT NOT NULL,
//     "st_class" TEXT NOT NULL,
//     "st_responsible" TEXT NOT NULL,
//     "st_mobile" TEXT NOT NULL,
//     "st_payment" INT,

//     FOREIGN KEY ("st_class") REFERENCES "classes" ("cl_id")
//                 ON DELETE NO ACTION ON UPDATE NO ACTION

//   )
//  ''');
//     print(" student table =====================================");

//     await batch.commit();
//   }

// // --------------------------------------------------

//   readData(String sql) async {
//     Database? mydb = await db;
//     List<Map> response = await mydb!.rawQuery(sql);
//     return response;
//   }

//   insertData(String sql) async {
//     Database? mydb = await db;
//     int response = await mydb!.rawInsert(sql);
//     return response;
//   }

//   updateData(String sql) async {
//     Database? mydb = await db;
//     int response = await mydb!.rawUpdate(sql);
//     return response;
//   }

//   deleteData(String sql) async {
//     Database? mydb = await db;
//     int response = await mydb!.rawDelete(sql);
//     return response;
//   }
// }
