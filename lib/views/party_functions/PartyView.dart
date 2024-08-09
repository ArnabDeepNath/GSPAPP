import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspappfinal/components/transactionCard.dart';
import 'package:gspappfinal/constants/AppColor.dart';
import 'package:gspappfinal/models/PartyModel.dart';

import 'package:gspappfinal/models/TransactionsModel.dart';
import 'package:gspappfinal/models/UserModel.dart';
import 'package:gspappfinal/providers/userProvider.dart';
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
          title: Text(
            'Party Details',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: AppColors.secondaryColor,
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

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: ${party.name}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Contact: ${party.contactNumber}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Balance: Rs. ${party.balance}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddSalePage(
                          user: widget.user,
                          party: widget.party,
                        ),
                      ),
                    );
                  },
                  child: const Text('Sale'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => addPaymentPage(
                          user: widget.user,
                          party: widget.party,
                        ),
                      ),
                    );
                  },
                  child: const Text('Payment In'),
                ),
              ],
            ),
            const SizedBox(
              height: 22,
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
