import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspappfinal/components/TextFormField.dart';
import 'package:gspappfinal/components/imagePicker.dart';
import 'package:gspappfinal/constants/AppColor.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gspappfinal/models/ItemModel.dart';
import 'package:gspappfinal/models/UserModel.dart';
import 'package:gspappfinal/providers/itemsProvider.dart';
import 'package:gspappfinal/providers/userProvider.dart';
import 'package:provider/provider.dart';

class AddItemsPage extends StatefulWidget {
  final UserModel user;
  const AddItemsPage({
    super.key,
    required this.user,
  });

  @override
  State<AddItemsPage> createState() => _AddItemsPageState();
}

class _AddItemsPageState extends State<AddItemsPage> {
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemHsnController = TextEditingController();
  TextEditingController itemPurchasePriceController = TextEditingController();
  TextEditingController itemSalePriceController = TextEditingController();
  TextEditingController itemTaxRateController = TextEditingController();
  TextEditingController itemPerUnitPriceController = TextEditingController();

  void clear() {
    itemNameController.clear();
    itemHsnController.clear();
    itemPerUnitPriceController.clear();
    itemPurchasePriceController.clear();
    itemSalePriceController.clear();
    itemTaxRateController.clear();
    setState(() {
      selectedImagePath = '';
    });
  }

  String dropdownValue = 'None';

  List<String> taxRates = [
    'None',
    'Exempted',
    'GST@0%',
    'IGST@0%',
    'GST@0.5%',
    'IGST@0.5%',
    'GST@3%',
    'IGST@3%',
    'GST@5%',
    'IGST@5%',
    'GST@12%',
    'IGST@12%',
    'GST@18%',
    'IGST@18%',
    'GST@28%',
    'IGST@28%',
  ];

  String? nonEmptyValidator(String? value) {
    if (value != null && value.isNotEmpty) {
      return null; // Field is not empty, so it's valid.
    }

    // Field is empty, so return an error message.
    return 'This field cannot be empty';
  }

  String? selectedImagePath;
  void _handleImageSelected(String imagePath) {
    setState(() {
      selectedImagePath = imagePath;
    });
  }

  bool _isAddingItem = false;
  bool _isAddingItemBulk = false;

  Future<void> _postItemToSubcollection() async {
    try {
      final itemsProvider = Provider.of<ItemsProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Validate all fields
      if (_validateFields()) {
        String? imageUrl;
        if (selectedImagePath != null) {
          final Reference storageReference = FirebaseStorage.instance.ref().child(
              'item_images/${widget.user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg');

          // Upload the file
          final TaskSnapshot uploadTask =
              await storageReference.putFile(File(selectedImagePath!));

          // Get the download URL
          imageUrl = await uploadTask.ref.getDownloadURL();
        } else {
          // Handle case where no image is selected
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select an image.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Create a new item
        final newItem = ItemModel(
          id: '',
          name: itemNameController.text,
          creationDate: Timestamp.now(),
          HSN: itemHsnController.text,
          purchasePrice: itemPurchasePriceController.text,
          salePrice: itemSalePriceController.text,
          taxRate: itemTaxRateController.text,
          unit: 'piece',
          img: imageUrl,
        );

        // Add the new item to the items list
        // itemsProvider.addItem(newItem);
        await userProvider.addItem(userId: widget.user.id, item: newItem);

        showSimpleDialog(context, 'Items Added');

        // Display a success message or navigate to a different screen
        clear();
      }
    } catch (e, stackTrace) {
      print('Error posting item: $e');
      print('Stack trace: $stackTrace');
      // Handle errors (show an error message, log, etc.)
    }
  }

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

  bool _validateFields() {
    if (itemNameController.text.isEmpty || selectedImagePath == null) {
      // Display an error message (you can customize this based on your UI)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields must be filled.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> showSimpleDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Message'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context); // Go back to the previous screen
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: const Icon(
              Icons.arrow_back, // Replace with your desired icon
              color: Colors.white, // Customize the icon color
              size: 24, // Customize the icon size
            ),
          ),
        ),
        title: Text(
          'Add New Item',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          InkWell(
            onTap: () async {
              setState(() {
                _isAddingItemBulk = true; // Show circular progress indicator
              });
              await _postBulkItems();
              setState(() {
                _isAddingItemBulk = false; // Hide circular progress indicator
              });
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white)),
              child: Center(
                child: _isAddingItem
                    ? const CircularProgressIndicator() // Show circular progress indicator
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.download,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Import',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 15),
                  child: Text(
                    'Item Details',
                    style: GoogleFonts.inter(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ),
                TextFormFieldCustom(
                  label: 'Item Name',
                  controller: itemNameController,
                  onChange: (value) {},
                  validator: nonEmptyValidator,
                  obscureText: false,
                ),
                TextFormFieldCustom(
                  label: 'Item Unit',
                  controller: itemPerUnitPriceController,
                  onChange: (value) {},
                  validator: nonEmptyValidator,
                  obscureText: false,
                ),
                TextFormFieldCustom(
                  label: 'Item Sale Price',
                  controller: itemSalePriceController,
                  onChange: (value) {},
                  validator: nonEmptyValidator,
                  obscureText: false,
                ),
                TextFormFieldCustom(
                  label: 'Item Purchase Price',
                  controller: itemPurchasePriceController,
                  onChange: (value) {},
                  validator: nonEmptyValidator,
                  obscureText: false,
                ),
                TextFormFieldCustom(
                  label: 'Item HSN',
                  controller: itemHsnController,
                  onChange: (value) {},
                  validator: nonEmptyValidator,
                  obscureText: false,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Upload Image',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomImagePicker(
                    onImageSelected: _handleImageSelected,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Tax Rate',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), // Shadow color
                          // Shadow color
                          offset: const Offset(0, 2), // Offset of the shadow
                          blurRadius: 4, // Blur radius of the shadow
                          spreadRadius: 1, // Spread radius of the shadow
                        ),
                      ],
                    ),
                    child: DropdownButton<String>(
                      alignment: AlignmentDirectional.center,
                      padding: EdgeInsets.all(8.0),
                      iconEnabledColor: Colors.black, // Icon color
                      value: dropdownValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                          itemTaxRateController.text = newValue;
                        });
                      },
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 232.0),
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ),
                      ), // Custom icon
                      underline: Container(),
                      items: taxRates
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 44,
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primaryColor)),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        _isAddingItem = true;
                      });
                      await _postItemToSubcollection();
                      setState(() {
                        _isAddingItem = false;
                      });
                    },
                    child: Container(
                      height: 44,
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: _isAddingItem
                            ? const CircularProgressIndicator()
                            : Text(
                                'Add Item',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
