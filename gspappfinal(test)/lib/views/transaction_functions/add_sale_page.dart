import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspappfinal/components/BreakdownComponent.dart';
import 'package:gspappfinal/components/QtyControl.dart';
import 'package:gspappfinal/components/TextFormField.dart';
import 'package:gspappfinal/components/dialogBox.dart';
import 'package:gspappfinal/constants/AppColor.dart';

import 'package:gspappfinal/models/ItemModel.dart';
import 'package:gspappfinal/models/PartyModel.dart';
import 'package:gspappfinal/models/TransactionsModel.dart';
import 'package:gspappfinal/models/UserModel.dart';
import 'package:gspappfinal/providers/userProvider.dart';
import 'package:provider/provider.dart';

class AddSalePage extends StatefulWidget {
  final UserModel? user;
  final PartyModel party;

  AddSalePage({
    super.key,
    required this.party,
    required this.user,
  });

  @override
  State<AddSalePage> createState() => _AddSalePageState();
}

class _AddSalePageState extends State<AddSalePage> {
  TextEditingController PNameController = TextEditingController();
  TextEditingController GSTIDController = TextEditingController();
  TextEditingController TotalAmount = TextEditingController();
  TextEditingController balanceController = TextEditingController();
  int QtyController = 0;

  // Party Controller Intiliasation

  // Fetching Items
  String? _selectedItem;
  List<String> _items = [];
  Map<String, Map<String, dynamic>> _itemDetails = {};
  Map<String, dynamic> _selectedItemDetails = {};

  List<Map<String, dynamic>> selectedItems = [];

  // Bool for Item Breakdown
  bool _itemSelected = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      PNameController.text = widget.party.name;
      GSTIDController.text = widget.party.GSTID;
    });
    _fetchItems();

    // print('Fetched items: $_items');
  }

  void clear() {
    PNameController.clear();
    GSTIDController.clear();
    TotalAmount.clear();
    balanceController.clear();
  }

  Future<void> _fetchItems() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('userId', isEqualTo: widget.user!.id)
          .get();
      Map<String, Map<String, dynamic>> itemDetails = {};
      for (var doc in querySnapshot.docs) {
        String itemName = doc.get('name');
        Map<String, dynamic> details = {
          'name': doc.get('name'),
          'salePrice': doc.get('salePrice'),
          'purchasePrice': doc.get('purchasePrice'),
          'taxRate': doc.get('taxRate'),
          'hsn': doc.get('HSN'),
          // Add other details as needed
        };
        itemDetails[itemName] = details;
      }
      setState(() {
        _itemDetails = itemDetails;
        _items = _itemDetails.keys.toList();
      });
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        title: Text(
          'Add Sale',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormFieldCustom(
                  label: 'Party Name',
                  controller: PNameController,
                  onChange: (text) {},
                  validator: (text) {
                    return null;
                  },
                  obscureText: false),
              TextFormFieldCustom(
                  label: 'GSTIN',
                  controller: GSTIDController,
                  onChange: (text) {},
                  validator: (text) {
                    return null;
                  },
                  obscureText: false),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton<String>(
                          value: _selectedItem,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedItem = newValue!;
                              _selectedItemDetails =
                                  _itemDetails[_selectedItem] ?? {};
                            });
                          },
                          items: _items.map<DropdownMenuItem<String>>((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedItem != null && QtyController > 0) {
                        double total = QtyController *
                            double.parse(
                                _selectedItemDetails['salePrice'] ?? '0.0');

                        selectedItems.add({
                          'itemName': _selectedItem,
                          'qty': QtyController,
                          'total': total,
                          'totalTax': _selectedItemDetails['taxRate'],
                        });
                        setState(() {
                          TotalAmount.text = selectedItems
                              .fold<int>(
                                  0,
                                  (sum, item) =>
                                      sum + (item['total'] as num).toInt())
                              .toStringAsFixed(2);
                          balanceController.text = "0.0";
                        });
                      }
                    },
                    child: Text(
                      'Add/Edit',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  )
                ],
              ),
              QuantityController(
                onChanged: (value) {
                  // Handle quantity change if needed
                  QtyController = value;
                },
                onItemSelected: (selected) {
                  setState(() {
                    _itemSelected = QtyController >= 1 ? selected : false;
                  });
                },
              ),
              Visibility(
                visible: _itemSelected,
                child: BreakDownComponent(
                  qty: QtyController,
                  unit: _selectedItemDetails['unit'] ?? 'NA',
                  salePrice: _selectedItemDetails['salePrice'] ?? '0.0',
                  taxRate: _selectedItemDetails['taxRate'] ?? '0.0',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
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
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(selectedItems[index]['itemName']),
                        subtitle: Text('Qty: ${selectedItems[index]['qty']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Total: ${double.parse(selectedItems[index]['total'].toString()).toStringAsFixed(2)}',
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  selectedItems.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              TextFormFieldCustom(
                  label: 'Total',
                  controller: TotalAmount,
                  onChange: (text) {},
                  validator: (text) {
                    return null;
                  },
                  obscureText: false),
              TextFormFieldCustom(
                  label: 'Balance',
                  controller: balanceController,
                  onChange: (text) {},
                  validator: (text) {
                    return null;
                  },
                  obscureText: false),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (PNameController != null && GSTIDController != null) {
// print(selectedItems);
                        final userProvider =
                            Provider.of<UserProvider>(context, listen: false);

                        userProvider.addTransaction(
                          widget.user,
                          TransactionModel(
                            amount: double.parse(TotalAmount.text),
                            description: '',
                            timestamp: Timestamp.now(),
                            reciever: widget.party.name,
                            sender: widget.user!.id,
                            balance: double.parse(balanceController.text),
                            isEditable: true,
                            recieverName: widget.party.name,
                            recieverId: widget.party.id,
                            transactionType: 'receive',
                            transactionId: '',
                            senderName: widget.user!.firstName,
                            selectedItems: selectedItems,
                          ),
                        );
                        clear();

                        showSimpleDialog(
                            context, 'Sale Transaction have been added');
                      } else {
                        showSimpleDialog(context, 'Please add all fields');
                      }
                    },
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
