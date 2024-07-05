import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspappfinal/components/dialogBox.dart';
import 'package:gspappfinal/constants/AppColor.dart';
import 'package:gspappfinal/models/ItemModel.dart';
import 'package:gspappfinal/models/UserModel.dart';
import 'package:gspappfinal/providers/itemsProvider.dart';
import 'package:gspappfinal/providers/userProvider.dart';
import 'package:gspappfinal/views/items_functions/AddItemsPage.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class emptyItemsPage extends StatefulWidget {
  final UserModel user;
  const emptyItemsPage({
    super.key,
    required this.user,
  });

  @override
  State<emptyItemsPage> createState() => _emptyItemsPageState();
}

class _emptyItemsPageState extends State<emptyItemsPage> {
  bool _isAddingItem = false;

  Future<void> _postBulkItems() async {
    try {
      // Open the file picker to select a CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        // Read the CSV file
        final input = file.openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(CsvToListConverter())
            .toList();

        // Get the itemsProvider and userProvider
        final itemsProvider =
            Provider.of<ItemsProvider>(context, listen: false);
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Parse each row of the CSV and add it as an item
        for (var row in fields) {
          String itemName = row[0];
          String itemHSN = row[1];
          String itemPurchasePrice = row[2].toString();
          String itemSalePrice = row[3].toString();
          String itemTaxRate = row[4].toString();
          String itemUnit = row[5];
          String itemImageUrl = row[6];

          // Create a new item
          final newItem = ItemModel(
            id: '',
            name: itemName,
            creationDate: Timestamp.now(),
            HSN: itemHSN,
            purchasePrice: itemPurchasePrice,
            salePrice: itemSalePrice,
            taxRate: itemTaxRate,
            unit: itemUnit,
            img: itemImageUrl,
          );

          // Add the new item to the items list
          await userProvider.addItem(userId: widget.user.id, item: newItem);
        }

        showSimpleDialog(context, 'Items added successfully from CSV');
      } else {
        // User canceled the picker
        showSimpleDialog(context, 'No file selected');
      }
    } catch (e, stackTrace) {
      print('Error posting bulk items: $e');
      print('Stack trace: $stackTrace');
      // Handle errors (show an error message, log, etc.)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Lottie.network(
              'https://lottie.host/b4706807-78ca-44b2-96a6-28d7b285842f/a55GfEZT50.json'),
          Center(
            child: Text(
              "You don't have any items , please add to view.",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddItemsPage(
                        user: widget.user,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 44,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Center(
                    child: Text(
                      'Add Items',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(
                height: 22,
              ),
              InkWell(
                onTap: () async {
                  setState(() {
                    _isAddingItem = true; // Show circular progress indicator
                  });
                  await _postBulkItems();
                  setState(() {
                    _isAddingItem = false; // Hide circular progress indicator
                  });
                },
                child: Container(
                  height: 44,
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _isAddingItem
                        ? CircularProgressIndicator() // Show circular progress indicator
                        : Text(
                            'Import Items',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
