import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

Future<String> customPDFGeneration(
  Timestamp date,
  String? name,
  String address,
  String phoneNumber,
  String email,
  String gstId,
  List<Map<String, dynamic>> transactions,
  String? username,
  String userId,
  String pdfType,
  PdfPageFormat format,
) async {
  final pdf = pw.Document();

  final logoData_1 = await rootBundle.load('images/logo1.jpg');
  final logoImage_1 = pw.MemoryImage(logoData_1.buffer.asUint8List());

  final logoData_2 = await rootBundle.load('images/logo2.jpg');
  final logoImage_2 = pw.MemoryImage(logoData_2.buffer.asUint8List());

  final logoData_3 = await rootBundle.load('images/signature.png');
  final signatureImg = pw.MemoryImage(logoData_3.buffer.asUint8List());

  final pw.TextStyle tableHeaderStyle = pw.TextStyle(
    fontSize: 8,
    fontWeight: pw.FontWeight.bold,
  );

  const pw.TextStyle tableHeaderStyle4 = pw.TextStyle(
    fontSize: 8,
  );

  final pw.TextStyle tableHeaderStyle3 = pw.TextStyle(
    fontSize: 6,
    fontWeight: pw.FontWeight.bold,
    background: const pw.BoxDecoration(
      color: PdfColors.grey300,
    ),
  );

  final pw.TextStyle tableContentStyle = pw.TextStyle(
    fontSize: 6,
    fontWeight: pw.FontWeight.bold,
  );

  final pw.TextStyle tableContentStyle2 = pw.TextStyle(
    fontSize: 6,
    fontWeight: pw.FontWeight.bold,
  );

  final pw.TextStyle tableContentStyle3 = pw.TextStyle(
    fontSize: 6,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  const pw.TextStyle tableContentStyle4 = pw.TextStyle(
    fontSize: 2,
    color: PdfColors.black,
  );

  const tableBorder = pw.TableBorder(
    left: pw.BorderSide(width: 1, color: PdfColors.black),
    top: pw.BorderSide(width: 1, color: PdfColors.black),
    right: pw.BorderSide(width: 1, color: PdfColors.black),
    bottom: pw.BorderSide(width: 1, color: PdfColors.black),
    horizontalInside: pw.BorderSide(width: 0, color: PdfColors.white),
    verticalInside: pw.BorderSide(width: 0, color: PdfColors.white),
  );

  // Assuming `widget.date` is a Firebase timestamp
  Timestamp timestamp = date;
  DateTime dateTime = timestamp.toDate();

  // Format the DateTime object into a string using DateFormat
  String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);

  final pagetheme = await _pageTheme(format);
  pdf.addPage(
    pw.Page(
      pageTheme: pagetheme,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  width: 80,
                  child: pw.Image(
                    logoImage_1,
                  ),
                ),
                pw.Container(
                  width: 80,
                  child: pw.Image(
                    logoImage_2,
                  ),
                ),
              ],
            ),
            pw.Text(
              'Meritfox Technologies Pvt. Ltd',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(
              height: 22,
            ),
            pw.SizedBox(
              width: 520,
              child: pw.Table.fromTextArray(
                cellStyle: tableContentStyle3,
                headerStyle: tableHeaderStyle3,
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                headerAlignments: {
                  0: pw.Alignment.center,
                },
                data: <List<String>>[
                  <String>[pdfType],
                ],
              ),
            ),
            pw.SizedBox(
              width: 520,
              child: pw.Table.fromTextArray(
                border: tableBorder,
                cellStyle: tableContentStyle2,
                headerStyle: tableHeaderStyle,
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.white,
                ),
                headerHeight: 12,
                cellHeight: 8,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                },
                data: <List<String?>>[
                  <String?>[
                    'PartyName',
                    name,
                  ],
                  <String>[
                    'Date',
                    formattedDate,
                  ],
                  <String>[
                    'Address',
                    address,
                  ],
                  <String>[
                    'Party GSTIN',
                    gstId,
                  ],
                  <String>[
                    'Mobile Number',
                    phoneNumber,
                  ],
                  <String>[
                    'Email',
                    email,
                  ],
                ],
              ),
            ),
            pw.SizedBox(
              width: 520,
              child: pw.Table.fromTextArray(
                border: tableBorder,
                cellStyle: tableContentStyle3,
                headerStyle: tableHeaderStyle3,
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                headerHeight: 12,
                cellHeight: 10,
                columnWidths: {
                  0: const pw.FixedColumnWidth(280),
                  1: const pw.FixedColumnWidth(60),
                  2: const pw.FixedColumnWidth(70),
                  3: const pw.FixedColumnWidth(50),
                  4: const pw.FixedColumnWidth(50),
                },
                headers: <String>[
                  'ITEM',
                  'HSN/SAC',
                  'GST RATE',
                  'QTY',
                  'TOTAL',
                ],
                data: transactions
                    .expand((transaction) {
                      final items = transaction['items'] as List<dynamic>?;
                      return items?.map((item) {
                            return [
                              item['itemName'] ?? 'N/A',
                              item['HSN'] ?? 'N/A',
                              item['totalTax'].toString(),
                              item['qty'].toString(),
                              item['total'].toString(),
                            ];
                          }).toList() ??
                          [];
                    })
                    .toList()
                    .cast<List<dynamic>>(), // Convert to List<List<String>>
              ),
            ),
            pw.SizedBox(
              width: 520,
              child: pw.Table.fromTextArray(
                cellStyle: tableContentStyle3,
                headerStyle: tableHeaderStyle3,
                headerAlignments: {
                  0: pw.Alignment.center,
                },
                data: <List<String>>[
                  <String>[''],
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  // Save PDF to the device
  final output = await getTemporaryDirectory();
  final file = File("${output.path}/output.pdf");
  await file.writeAsBytes(await pdf.save());

  return file.path;
}

Future<pw.PageTheme> _pageTheme(PdfPageFormat format) async {
  final image = pw.MemoryImage(
      (await rootBundle.load('images/watermark.jpg')).buffer.asUint8List());
  return pw.PageTheme(
    margin: pw.EdgeInsets.zero,
    pageFormat: PdfPageFormat.a4,
    buildBackground: ((context) => pw.FullPage(
          ignoreMargins: false,
          child: pw.Watermark(
            angle: 32,
            child: pw.Opacity(
              opacity: 0.15,
              child: pw.Image(image),
            ),
          ),
        )),
  );
}
