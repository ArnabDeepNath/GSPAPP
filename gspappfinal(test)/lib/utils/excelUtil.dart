import 'dart:io';

import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

Future<String> createExcelFile() async {
  var excel = Excel.createExcel();

  excel.rename('Sheet1', 'b2b,sez,de');

  var sheet1 = excel['b2b,sez,de'];

  sheet1.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  // Add totals to the sheet

  // sheet1.appendRow([
  //   TextCellValue(totalRecipients.toString()),
  //   TextCellValue(''),
  //   TextCellValue(totalInvoices.toString()),
  //   TextCellValue(''),
  //   TextCellValue(totalInvoiceValue.toString()),
  //   TextCellValue(''),
  //   TextCellValue(''),
  //   TextCellValue(''),
  //   TextCellValue(''),
  //   TextCellValue(''),
  //   TextCellValue(''),
  //   TextCellValue(totalTaxableValue.toString()),
  //   TextCellValue(totalCess.toString()),
  // ]);

  sheet1.appendRow([
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
  ]);

  sheet1.appendRow([
    TextCellValue('Invoice Date'),
    TextCellValue('Invoice Value'),
    TextCellValue('Place of Supply'),
    TextCellValue('Reverse Charge'),
    TextCellValue('Appliable % of Tax Rate'),
    TextCellValue('Invoice Type'),
    TextCellValue('Ecommerce GSTIN'),
    TextCellValue('Rate'),
    TextCellValue('Taxable Value'),
    TextCellValue('Cess Amount'),
  ]);

  // for (var transaction in transactions) {
  //   DateTime invoiceDate = DateTime.fromMillisecondsSinceEpoch(
  //       transaction['timestamp'].millisecondsSinceEpoch);
  //   String formattedInvoiceDate = DateFormat('yyyy-MM-dd').format(invoiceDate);
  //   // Iterate over selectedItems list for each transaction
  //   String totalTax = '';
  //   // Check if selectedItems is not null and is iterable
  //   if (transaction['selectedItems'] != null &&
  //       transaction['selectedItems'] is Iterable) {
  //     // Iterate over selectedItems list for each transaction
  //     for (var item in transaction['selectedItems']) {
  //       if (item != null && item is Map && item.containsKey('totalTax')) {
  //         totalTax += item['totalTax'].toString() +
  //             ', '; // Assuming totalTax is a number
  //       }
  //     }
  //     if (totalTax.isNotEmpty) {
  //       totalTax = totalTax.substring(
  //           0, totalTax.length - 2); // Remove the last comma and space
  //     }
  //   }
  //   sheet1.appendRow([
  //     TextCellValue(formattedInvoiceDate),
  //     TextCellValue(transaction['amount'].toString()),
  //     TextCellValue('18-Assam'),
  //     TextCellValue('N'),
  //     TextCellValue('65%'),
  //     TextCellValue('Regular B2B'),
  //     TextCellValue(''),
  //     TextCellValue(totalTax),
  //     TextCellValue(''),
  //     TextCellValue(''),
  //   ]);
  // }

  // B2B Section
  var sheet2 = excel['b2ba'];

  sheet2.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  var sheet3 = excel['b2c'];

  sheet3.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  var sheet4 = excel['b2cl'];

  sheet4.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  var sheet5 = excel['b2cs'];

  sheet5.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  var sheet6 = excel['b2csa'];

  sheet6.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  var sheet7 = excel['cdnr'];

  sheet7.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  var sheet8 = excel['cdnra'];

  sheet8.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  var sheet9 = excel['cdnur'];

  sheet9.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  var sheet10 = excel['cdnura'];

  sheet10.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  var sheet11 = excel['exp'];

  sheet11.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  var sheet12 = excel['expa'];

  sheet12.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  var sheet13 = excel['at'];

  sheet13.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  var sheet14 = excel['ata'];

  sheet14.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  var sheet15 = excel['atdj'];

  sheet15.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  var sheet16 = excel['atdja'];

  sheet16.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  var sheet17 = excel['exemp'];

  sheet17.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  var sheet18 = excel['hsn'];

  sheet18.appendRow([
    TextCellValue('HSN'),
    TextCellValue('Description'),
    TextCellValue('UQC'),
    TextCellValue('Total Quantity'),
    TextCellValue('Total Value'),
    TextCellValue('Taxable Value'),
    TextCellValue('Intregated Tax Amount'),
    TextCellValue('Central Tax Amount'),
    TextCellValue('State/UT Tax Amount'),
    TextCellValue('Cess Amount'),
    TextCellValue('Rate'),
    TextCellValue('Total Cess'),
  ]);

  // for (var transaction in transactions) {
  //   DateTime invoiceDate = DateTime.fromMillisecondsSinceEpoch(
  //       transaction['timestamp'].millisecondsSinceEpoch);
  //   String formattedInvoiceDate = DateFormat('yyyy-MM-dd').format(invoiceDate);

  //   String hsnCodes = '';
  //   double totalQty = 0;
  //   double totalValue = 0.0;
  //   String TaxableValue = '';
  //   String IntregatedTaxAmount = '';
  //   String CentralTaxAmount = '';
  //   String StateTaxAmount = '';
  //   double CessAmount = 0.0;
  //   String Rate = '';

  //   // Check if selectedItems is not null and is iterable
  //   if (transaction['selectedItems'] != null &&
  //       transaction['selectedItems'] is Iterable) {
  //     // Iterate over selectedItems list for each transaction
  //     for (var item in transaction['selectedItems']) {
  //       if (item != null && item is Map) {
  //         hsnCodes +=
  //             item['hsnCode'].toString() + ', '; // Assuming hsnCode is a string
  //         totalQty += item['qty'];
  //         totalValue += item['total'];
  //       }
  //     }
  //     if (hsnCodes.isNotEmpty) {
  //       hsnCodes = hsnCodes.substring(
  //           0, hsnCodes.length - 2); // Remove the last comma and space
  //     }
  //   }

  //   sheet18.appendRow([
  //     TextCellValue(hsnCodes),
  //     TextCellValue(''),
  //     TextCellValue('UQC'),
  //     TextCellValue(totalQty.toString()),
  //     TextCellValue(totalValue.toString()),
  //     TextCellValue(TaxableValue),
  //     TextCellValue(''),
  //     TextCellValue(''),
  //     TextCellValue(''),
  //     TextCellValue(CessAmount.toString()),
  //     TextCellValue(Rate),
  //   ]);
  // }

  var sheet19 = excel['docs'];

  sheet19.appendRow([
    TextCellValue('No. of Receipients'),
    TextCellValue(''),
    TextCellValue('No. of invoices'),
    TextCellValue(''),
    TextCellValue('Total Invoice Value'),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue(''),
    TextCellValue('Total Taxable Value'),
    TextCellValue('Total Cess'),
  ]);

  // Save the Excel file to the app-specific directory
  String tempDir = (await getApplicationDocumentsDirectory()).path;
  String tempFilePath = '$tempDir/GSTR1_Report.xlsx';
  List<int>? fileBytes = excel.save();
  if (fileBytes != null) {
    File file = File(tempFilePath);
    if (await file.exists()) {
      await file.delete();
    }
    await file.create(recursive: true);
    await file.writeAsBytes(fileBytes);
    print('File saved to app-specific directory: $tempFilePath');
  }

  return tempFilePath;
}
