import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspappfinal/components/transactionCard.dart';
import 'package:gspappfinal/constants/AppColor.dart';
import 'package:gspappfinal/models/PartyModel.dart';

import 'package:gspappfinal/models/TransactionsModel.dart';
import 'package:gspappfinal/models/UserModel.dart';
import 'package:gspappfinal/providers/userProvider.dart';
import 'package:gspappfinal/utils/part_details_card.dart';
import 'package:gspappfinal/views/transaction_functions/addPaymentPage.dart';
import 'package:gspappfinal/views/transaction_functions/add_sale_page.dart';
import 'package:provider/provider.dart';

class PartyDetailsPage extends StatefulWidget {
  final PartyModel party;
  final UserModel? user;

  PartyDetailsPage({
    required this.party,
    required this.user,
  });

  @override
  State<PartyDetailsPage> createState() => _PartyDetailsPageState();
}

class _PartyDetailsPageState extends State<PartyDetailsPage> {
  late Stream<DocumentSnapshot> partyStream;
  late Stream<QuerySnapshot> transactionStream;

  @override
  void initState() {
    super.initState();
    partyStream = FirebaseFirestore.instance
        .collection('parties')
        .doc(widget.party.id)
        .snapshots();

    transactionStream = FirebaseFirestore.instance
        .collection('transactions')
        .where('partyId', isEqualTo: widget.party.id)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
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
            'Party Details',
            style: GoogleFonts.inter(
              fontSize: 24,
              color: Colors.white
            ),
          ),
        ),
        body: Column(
          children: [
            StreamBuilder(
              stream: partyStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                DocumentSnapshot<Map<String, dynamic>> document =
                    snapshot.data as DocumentSnapshot<Map<String, dynamic>>;
                PartyModel party = PartyModel.fromFirestore(document);

                return PartyDetailsCard(
                    party: Party(
                        name: party.name,
                        contactNumber: party.contactNumber,
                        balance: double.parse(party.balance)));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddSalePage(
                          user: widget.user,
                          party: widget.party,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 44,
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 2),
                        Text(
                          'Add Sale',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => addPaymentPage(
                          user: widget.user,
                          party: widget.party,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 44,
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 2),
                        Text(
                          'Add Payment In',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(
              height: 70,
            ),
            Expanded(
              child: StreamBuilder(
                stream: transactionStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  QuerySnapshot<Map<String, dynamic>> querySnapshot =
                      snapshot.data as QuerySnapshot<Map<String, dynamic>>;
                  List<TransactionModel> transactions = querySnapshot.docs
                      .map((doc) => TransactionModel.fromFirestore(doc))
                      .toList();

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return transactionCard(
                        transaction: transactions[index],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
