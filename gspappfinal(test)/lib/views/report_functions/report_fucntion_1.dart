import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspappfinal/components/dialogBox.dart';
import 'package:gspappfinal/constants/AppColor.dart';
import 'package:gspappfinal/models/UserModel.dart';
import 'package:gspappfinal/utils/excelUtil.dart';
import 'package:gspappfinal/utils/pdfUtil.dart';
import 'package:gspappfinal/views/report_functions/ReportGenerationScreen.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';

class ReportFunction extends StatefulWidget {
  final UserModel user;

  ReportFunction({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ReportFunction> createState() => _ReportFunctionState();
}

class _ReportFunctionState extends State<ReportFunction> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        title: Text(
          'Reports',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: AppColors.secondaryColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButton<String>(
              hint: Text('Generate Report'),
              value: _selectedOption,
              onChanged: (String? value) {
                setState(() {
                  _selectedOption = value;
                });
              },
              items: [
                'Transaction',
                'GSTR1/Excel',
                'GSTR1/PDF',
                'GSTR3A',
                'JSON Report',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Container(
              height: 500,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (_selectedOption == 'Transaction') {
                      // Generate GSTR1 PDF report
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ReportGeneration(),
                        ),
                      );
                    } else if (_selectedOption == 'GSTR1/Excel') {
                      String filepath = await createExcelFile();
                      final List<XFile> files = [XFile(filepath)];
                      Share.shareXFiles(files, text: 'Check out this file!');
                    } else if (_selectedOption == 'JSON Report') {
                      showSimpleDialog(context,
                          'JSON file saved in gspappfinal/dir/GST_report.json');
                    }
                  },
                  child: Text('Generate Report'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Background color
                  ),
                  onPressed: () {
                    showSimpleDialog(context,
                        '500 - Internal Server Error , API not working');
                  },
                  child: Container(
                    child: Text(
                      'One Click GST Filing',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, String reportType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Report Format'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _generateReport(context, reportType, 'pdf');
                },
                child: Text('PDF'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _generateReport(context, reportType, 'excel');
                },
                child: Text('Excel'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _generateReport(
      BuildContext context, String reportType, String format) async {
    try {
      final transactionsCollection =
          FirebaseFirestore.instance.collection('transactions');

      // Fetch transactions of type 'receive' for the given party
      // QuerySnapshot transactionDocs = await transactionsCollection
      //     .where('partyId', isEqualTo: widget.party.id)
      //     .where('transactionType', isEqualTo: 'receive')
      //     .get();

      // List<Map<String, dynamic>> transactions = transactionDocs.docs.map((doc) {
      //   return doc.data() as Map<String, dynamic>;
      // }).toList();

      // Calculate the total amount for 'receive' transactions
      // double totalAmount = transactions.fold(0.0, (sum, transaction) {
      //   return sum + (transaction['totalAmount'] ?? 0.0);
      // });

      // Generate report (PDF or Excel)
      // if (format == 'pdf') {
      //   _generatePDFReport(transactions, totalAmount, reportType);
      // } else if (format == 'excel') {
      //   _generateExcelReport(transactions, totalAmount, reportType);
      // }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report generated successfully')),
      );
    } catch (e) {
      print('Error generating report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report')),
      );
    }
  }

  void _generatePDFReport(List<Map<String, dynamic>> transactions,
      double totalAmount, String reportType) {
    // Implement PDF report generation logic here
  }

  void _generateExcelReport(List<Map<String, dynamic>> transactions,
      double totalAmount, String reportType) {
    // Implement Excel report generation logic here
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String filePath;
  final bool share;

  const PDFViewerScreen({
    Key? key,
    required this.filePath,
    this.share = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice"),
        actions: [
          if (share)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                Share.shareFiles([filePath]);
              },
              child: const Text('Share PDF'),
            ),
        ],
      ),
      ////////////pdf view
      body: Container(),
    );
  }
}
