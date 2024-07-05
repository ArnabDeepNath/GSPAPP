import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspappfinal/components/TextFormField.dart';
import 'package:gspappfinal/components/dialogBox.dart';
import 'package:gspappfinal/constants/AppColor.dart';

import 'package:gspappfinal/models/PartyModel.dart';
import 'package:gspappfinal/models/TransactionsModel.dart';
import 'package:gspappfinal/models/UserModel.dart';
import 'package:gspappfinal/providers/userProvider.dart';
import 'package:provider/provider.dart';

class addPaymentPage extends StatefulWidget {
  final UserModel? user;
  final PartyModel party;

  addPaymentPage({super.key, required this.user, required this.party});

  @override
  State<addPaymentPage> createState() => _addPaymentPageState();
}

class _addPaymentPageState extends State<addPaymentPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Payment',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: AppColors.secondaryColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              TextFormFieldCustom(
                  label: 'Name',
                  controller: nameController,
                  onChange: (value) {},
                  validator: (value) {
                    return null;
                  },
                  obscureText: false),
              TextFormFieldCustom(
                  label: 'Amount',
                  controller: amountController,
                  onChange: (value) {},
                  validator: (value) {
                    return null;
                  },
                  obscureText: false),
              TextFormFieldCustom(
                  label: 'Description',
                  controller: descriptionController,
                  onChange: (value) {},
                  validator: (value) {
                    return null;
                  },
                  obscureText: false),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final userProvider =
                          Provider.of<UserProvider>(context, listen: false);

                      userProvider.addTransaction(
                        widget.user,
                        TransactionModel(
                          amount: double.parse(amountController.text),
                          description: '',
                          timestamp: Timestamp.now(),
                          reciever: widget.party.name,
                          sender: widget.user!.id,
                          balance: 0.0,
                          isEditable: true,
                          recieverName: widget.party.name,
                          recieverId: widget.party.id,
                          transactionType: 'payment',
                          transactionId: '',
                          senderName: widget.user!.firstName,
                          selectedItems: [],
                        ),
                      );
                      showSimpleDialog(context, 'Payment have been added');
                    },
                    child: Text('Add Payment'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Cancel'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
