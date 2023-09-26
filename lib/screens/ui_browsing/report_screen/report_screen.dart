import 'package:flutter/material.dart';

import 'reports/paid_fees.dart';
import 'reports/unpaid_fees.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("التقارير"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _gotoUnPaidFees,
              icon: const Icon(Icons.money_off),
              label: const Text("طلاب لم يستوفوا الرسوم"),
            ),
            ElevatedButton.icon(
              onPressed: _gotoPaidFees,
              icon: const Icon(Icons.how_to_reg_sharp),
              label: const Text("الطلاب الذين استوفوا الرسوم"),
            ),
            // ElevatedButton.icon(
            //   onPressed: _classesBrowser,
            //   icon: const Icon(Icons.class_),
            //   label: const Text("تصفح الصفوف"),
            // ),
            // ElevatedButton.icon(
            //   onPressed: _reportBrowser,
            //   icon: const Icon(Icons.receipt_long_outlined),
            //   label: const Text("التقارير"),
            // ),
          ],
        ),
      ),
    );
  }

  void _gotoUnPaidFees() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const UnpaidFeesWindwo()));
  }

  void _gotoPaidFees() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaidFeesWindow()),
    );
  }

  // void _classesBrowser() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const ClassesData()),
  //   );
  // }

  // void _reportBrowser() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const ReportScreen()),
  //   );
  // }

  //   );
  // }
}
