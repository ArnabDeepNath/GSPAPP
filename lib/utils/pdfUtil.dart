import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

Future<String> generatePDF_GST(
  // First Header

  Timestamp date,
  // Second Header
  String name,
  String address,
  String phoneNumber,
  String email,
  String gstId,

  // Third Header (Calculation Module)

  // GST Module

  // Misceleanous Module
  List items,
  // User Details
  String username,
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

  pw.TextStyle tableHeaderStyle3 = pw.TextStyle(
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
        return pw.Positioned(
          top: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Positioned(
                    child: pw.Container(
                      width: 80,
                      child: pw.Image(
                        logoImage_1,
                      ),
                    ),
                  ),
                  pw.Positioned(
                    child: pw.Container(
                      width: 80,
                      child: pw.Image(
                        logoImage_2,
                      ),
                    ),
                  ),
                ],
              ),
              pw.Positioned(
                child: pw.Text(
                  'Meritfox Technologies Pvt. Ltd',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(
                height: 22,
              ),
              pw.Positioned(
                child: pw.SizedBox(
                  width: 520,
                  child: pw.Positioned(
                    top: 300,
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
                ),
              ),
              pw.Positioned(
                child: pw.SizedBox(
                  width: 520,
                  child: pw.Positioned(
                    child: pw.Table.fromTextArray(
                      border: tableBorder,
                      cellStyle: tableContentStyle2,
                      headerStyle: tableHeaderStyle,
                      headerDecoration: const pw.BoxDecoration(
                        color: PdfColors.white,
                      ),
                      cellAlignments: {
                        0: pw.Alignment.centerLeft,
                        1: pw.Alignment.centerLeft,
                        2: pw.Alignment.centerLeft,
                        3: pw.Alignment.centerRight,
                      },
                      // cellAlignment: pw.Alignment.center,
                      data: <List<String>>[
                        <String>[''],
                        <String>['Quotation No:    '],
                        <String>['Date:     $formattedDate'],
                        <String>[''],
                      ],
                    ),
                  ),
                ),
              ),
              pw.Positioned(
                bottom: 125,
                child: pw.SizedBox(
                  width: 520,
                  child: pw.Positioned(
                    top: 300,
                    child: pw.Table.fromTextArray(
                      border: tableBorder,
                      cellStyle: tableContentStyle,
                      headerStyle: tableHeaderStyle,
                      cellAlignments: {
                        0: pw.Alignment.centerLeft,
                        1: pw.Alignment.bottomLeft,
                      },
                      data: <List<String>>[
                        <String>[''],
                        <String>[
                          'Name: $username',
                          // I want to use the local variable here
                        ],
                        <String>[
                          'Phone No:      $phoneNumber',
                        ],
                        <String>[
                          'Email: ',
                          email,
                        ],
                        <String>[
                          'GST No: ',
                        ],
                        <String>[
                          '',
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              pw.Positioned(
                top: 125,
                child: pw.SizedBox(
                  width: 520,
                  child: pw.Positioned(
                    child: pw.Table.fromTextArray(
                      cellStyle: tableContentStyle,
                      headerStyle: tableHeaderStyle,
                      headerDecoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      cellAlignments: {
                        0: pw.Alignment.center,
                        1: pw.Alignment.center,
                        2: pw.Alignment.center,
                        3: pw.Alignment.center,
                        4: pw.Alignment.center,
                        5: pw.Alignment.center,
                      },
                      headerAlignments: {
                        0: pw.Alignment.center,
                      },
                      data: <List<dynamic>>[
                        <String>[
                          'Items',
                          'Quantity',
                          'Unit Price',
                          'Amount',
                        ],
                        <String>[
                          '',
                          '',
                          '',
                          '',
                        ],
                        <String>[
                          'SGST',
                          '',
                          '',
                          '',
                        ],
                        <String>[
                          'CGST',
                          '',
                          '',
                          '',
                        ],
                        <String>[
                          '',
                          '',
                          '',
                          '',
                        ],
                        ...items
                            .map((item) => [
                                  item['itemName'],
                                  item['qty'].toString(),
                                  '',
                                  'Rs. ${item['total'].toString()}',
                                ])
                            .toList(),
                        <String>[
                          'Grand Total',
                          '',
                          '',
                          '',
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              pw.Positioned(
                bottom: 125,
                child: pw.SizedBox(
                  width: 520,
                  child: pw.Positioned(
                    top: 300,
                    child: pw.Table.fromTextArray(
                      defaultColumnWidth: const pw.FixedColumnWidth(150),
                      cellStyle: tableContentStyle4,
                      headerStyle: tableHeaderStyle4,
                      // headerDecoration: const pw.BoxDecoration(
                      //   color: PdfColors.white,
                      // ),
                      cellAlignments: {
                        0: pw.Alignment.topLeft,
                        1: pw.Alignment.center,
                        2: pw.Alignment.center,
                        3: pw.Alignment.center,
                        4: pw.Alignment.center,
                        5: pw.Alignment.center,
                      },
                      headerAlignments: {
                        0: pw.Alignment.centerLeft,
                      },
                      cellAlignment: pw.Alignment.topLeft,
                      data: <List<String>>[
                        <String>['.'],
                      ],
                    ),
                  ),
                ),
              ),
              pw.Positioned(
                bottom: 165,
                child: pw.Container(
                  width: 520,
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Text(
                        'Company will not be responsible for any transaction in cash except \ncash counter',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Positioned(
                    bottom: 105,
                    child: pw.SizedBox(
                      width: 520,
                      child: pw.Positioned(
                        top: 300,
                        child: pw.Table.fromTextArray(
                          defaultColumnWidth: const pw.FixedColumnWidth(30),
                          cellStyle: tableContentStyle,
                          headerStyle: tableHeaderStyle,
                          headerDecoration: const pw.BoxDecoration(
                            color: PdfColors.grey300,
                          ),
                          cellAlignments: {
                            0: pw.Alignment.center,
                            1: pw.Alignment.center,
                            2: pw.Alignment.center,
                            3: pw.Alignment.center,
                            4: pw.Alignment.center,
                            5: pw.Alignment.center,
                          },
                          headerAlignments: {
                            0: pw.Alignment.centerRight,
                          },
                          cellAlignment: pw.Alignment.center,
                          data: <List<String>>[
                            <String>[
                              'GST No: $gstId',
                              'PAN No.:  ',
                            ],
                            <String>[
                              'Created By : $userId ',
                              'User ID.: $username',
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  pw.Positioned(
                    child: pw.Container(
                      width: 100,
                      child: pw.Image(
                        signatureImg,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );

  // Create a file to save the PDF
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/invoice_.pdf');

  // Save the PDF to the file
  final pdfBytes = await pdf.save();
  await file.writeAsBytes(pdfBytes.buffer.asInt8List());

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
