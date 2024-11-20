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
          'Add Payment',
          style: GoogleFonts.inter(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: AppColors.secondaryColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10,),
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
              const SizedBox(height: 30.0),
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
                    child: Container(
                      height: 44,
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child:Text(
                          'Save',
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
