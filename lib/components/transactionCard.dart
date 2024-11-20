import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gspappfinal/models/TransactionsModel.dart';
import 'package:gspappfinal/utils/pdfUtil.dart';
import 'package:gspappfinal/views/report_functions/report_fucntion_1.dart';
import 'package:pdf/pdf.dart';

class transactionCard extends StatefulWidget {
  final TransactionModel transaction;

  const transactionCard({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  State<transactionCard> createState() => _transactionCardState();
}

class _transactionCardState extends State<transactionCard> {
  void _deleteTransaction(String transactionId, String userId) async {
    try {
      final transactionsCollection =
          FirebaseFirestore.instance.collection('transactions');

      // Get the transaction details before deleting
      DocumentSnapshot transactionDoc =
          await transactionsCollection.doc(transactionId).get();
      if (!transactionDoc.exists) {
        throw ('Transaction not found');
      }

      Map<String, dynamic> transactionData =
          transactionDoc.data() as Map<String, dynamic>; // Get transaction data

      String transactionType = transactionData['transactionType'];

      // Delete the transaction
      await transactionsCollection.doc(transactionId).delete();

      // Remove the transaction ID from the user's transactions list
      final userCollection = FirebaseFirestore.instance.collection('users');
      DocumentSnapshot userDoc = await userCollection.doc(userId).get();
      if (userDoc.exists) {
        List<dynamic> transactions = userDoc['transactions'];
        transactions.remove(transactionId);
        await userCollection.doc(userId).update({'transactions': transactions});
      }

      // Check if the transaction is a credit note or debit note
      if (transactionType == 'credit_note' || transactionType == 'debit_note') {
        // Do not update party balance for credit notes or debit notes
        return;
      }

      // Update the party's balance for other transaction types
      double amount = transactionData['totalAmount'];
      String partyId = transactionData['partyId'];

      // Update the party's balance
      final partyCollection = FirebaseFirestore.instance.collection('parties');
      DocumentSnapshot partyDoc = await partyCollection.doc(partyId).get();
      if (partyDoc.exists) {
        double currentBalance =
            double.parse(partyDoc['balance'] ?? '0.0') ?? 0.0;
        String balanceType = partyDoc['balanceType'];

        // Adjust the balance based on the transaction amount
        if (transactionData['transactionType'] == balanceType) {
          currentBalance -= amount.abs();
        } else {
          currentBalance += amount.abs();
        }

        String newBalanceType = balanceType;

        if (balanceType == 'payment' &&
            transactionData['transactionType'] == 'receive') {
          newBalanceType = currentBalance > 0 ? 'payment' : 'receive';
        } else if (balanceType == 'receive' &&
            transactionData['transactionType'] == 'payment') {
          newBalanceType = currentBalance > 0 ? 'receive' : 'payment';
        } else if (balanceType == 'receive' &&
            transactionData['transactionType'] == 'receive') {
          newBalanceType = currentBalance > 0 ? 'receive' : 'payment';
        } else if (balanceType == 'payment' &&
            transactionData['transactionType'] == 'payment') {
          newBalanceType = currentBalance > 0 ? 'payment' : 'receive';
        }

        await partyCollection.doc(partyId).update({
          'balance': currentBalance.abs().toString(),
          'balanceType': newBalanceType,
        });
      }
    } catch (e) {
      print('Error deleting transaction: $e');
      throw e;
    }
  }

  Future<void> createReferenceTransaction(String transactionId) async {
    try {
      final transactionsCollection =
          FirebaseFirestore.instance.collection('transactions');

      // Get the original transaction details
      DocumentSnapshot transactionDoc =
          await transactionsCollection.doc(transactionId).get();
      if (!transactionDoc.exists) {
        throw ('Transaction not found');
      }

      Map<String, dynamic> transactionData =
          transactionDoc.data() as Map<String, dynamic>; // Get transaction data

      String originalType = transactionData['transactionType'];
      String referenceType =
          (originalType == 'receive') ? 'credit_note' : 'debit_note';

      // Create a new transaction with the reference type
      DocumentReference newTransactionRef;
      newTransactionRef = await transactionsCollection.add({
        'userId': transactionData['userId'],
        'partyId': transactionData['partyId'],
        'items': transactionData['items'],
        'totalAmount': transactionData['totalAmount'],
        'balance': transactionData['balance'],
        'description': 'Reference transaction for $originalType',
        'timestamp': Timestamp.now(),
        'reciever': transactionData['reciever'],
        'sender': transactionData['sender'],
        'isEditable': true,
        'recieverName': transactionData['recieverName'],
        'recieverId': transactionData['recieverId'],
        'transactionType': referenceType,
        'senderName': transactionData['senderName'],
        'selectedItems': transactionData['selectedItems'],
      });

      // Update the transaction ID with the new transaction's ID
      await newTransactionRef.update({'transactionId': newTransactionRef.id});

      // Update the reference transaction ID in the new transaction
      await newTransactionRef.update({'referenceTransactionId': transactionId});

      // Update the party's balance accordingly
      final partyCollection = FirebaseFirestore.instance.collection('parties');
      DocumentSnapshot partyDoc =
          await partyCollection.doc(transactionData['partyId']).get();
      // if (partyDoc.exists) {
      //   double currentBalance =
      //       double.parse(partyDoc['balance'] ?? '0.0') ?? 0.0;
      //   double amount = transactionData['totalAmount'];

      //   // if (referenceType == 'credit_note') {
      //   //   currentBalance += amount;
      //   // } else if (referenceType == 'debit_note') {
      //   //   currentBalance -= amount;
      //   // }

      //   // await partyCollection.doc(transactionData['partyId']).update({
      //   //   'balance': currentBalance.toString(),
      //   // });
      // }

      print('Reference transaction created successfully');
    } catch (e) {
      print('Error creating reference transaction: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.15,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ListTile(
                title: Text(
                  widget.transaction.recieverName,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance: ${widget.transaction.balance}',
                    ),
                    Text(
                      widget.transaction.transactionType == 'receive'
                          ? 'Sale'
                          : widget.transaction.transactionType == 'payment'
                              ? 'Payment In'
                              : widget.transaction.transactionType ==
                                      'credit_note'
                                  ? 'Credit Note'
                                  : 'Debit Note',
                      style: TextStyle(
                        color:
                            widget.transaction.transactionType == 'receive' ||
                                    widget.transaction.transactionType ==
                                        'credit_note'
                                ? Colors.green
                                : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  'Rs. ${widget.transaction.amount >= 0 ? widget.transaction.amount : widget.transaction.amount.abs()}',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.green.shade600,
                  ),
                ),
              ),
              if (widget.transaction.isEditable == true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (widget.transaction.transactionType == 'payment')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            // Handle generate payment out
                            createReferenceTransaction(
                                widget.transaction.transactionId);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.payment_outlined,
                                color: Colors.black.withOpacity(0.7),
                              ),
                              Text(
                                'Generate Debit Note',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (widget.transaction.transactionType == 'receive')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () async {
                            createReferenceTransaction(
                                widget.transaction.transactionId);
                            // Handle payment in
                            // String filepath = await generatePDF_GST(
                            //   Timestamp.now(),
                            //   widget.transaction.recieverName,
                            //   '',
                            //   '',
                            //   '',
                            //   '',
                            //   widget.transaction.selectedItems,
                            //   widget.transaction.senderName!,
                            //   widget.transaction.sender!,
                            //   'Credit Note',
                            //   PdfPageFormat.a4,
                            // );
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => PDFViewerScreen(
                            //       filePath: filepath,
                            //       share: true,
                            //     ),
                            //   ),
                            // );
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.payment_outlined,
                                color: Colors.black.withOpacity(0.7),
                              ),
                              Text(
                                'Generate Credit Note',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (widget.transaction.transactionType == 'credit_note' ||
                        widget.transaction.transactionType == 'debit_note')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () async {
                            // Handle return
                            String filepath = await generatePDF_GST(
                              Timestamp.now(),
                              widget.transaction.recieverName,
                              '',
                              '',
                              '',
                              '',
                              widget.transaction.selectedItems,
                              widget.transaction.senderName!,
                              widget.transaction.sender!,
                              'Return Note',
                              PdfPageFormat.a4,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PDFViewerScreen(
                                  filePath: filepath,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.reply,
                                color: Colors.black.withOpacity(0.7),
                              ),
                              Text(
                                ' Return',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (widget.transaction.transactionType == 'credit_note' ||
                        widget.transaction.transactionType == 'debit_note')
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert),
                        onSelected: (String value) async {
                          // Handle menu item selection
                          switch (value) {
                            case 'Return':
                              String filepath = await generatePDF_GST(
                                Timestamp.now(),
                                widget.transaction.recieverName,
                                '',
                                '',
                                '',
                                '',
                                widget.transaction.selectedItems,
                                widget.transaction.senderName!,
                                widget.transaction.sender!,
                                'Return Note',
                                PdfPageFormat.a4,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFViewerScreen(
                                    filePath: filepath,
                                  ),
                                ),
                              );
                              break;
                            case 'DeliveryChallan':
                              String filepath = await generatePDF_GST(
                                Timestamp.now(),
                                widget.transaction.recieverName,
                                '',
                                '',
                                '',
                                '',
                                widget.transaction.selectedItems,
                                widget.transaction.senderName!,
                                widget.transaction.sender!,
                                'Delivery Challan',
                                PdfPageFormat.a4,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFViewerScreen(
                                    filePath: filepath,
                                  ),
                                ),
                              );
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'Return',
                            child: Text('Generate Invoice'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'DeliveryChallan',
                            child: Text('Delivery Challan'),
                          ),
                        ],
                      ),
                    if (widget.transaction.transactionType == 'receive' ||
                        widget.transaction.transactionType == 'payment')
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert),
                        onSelected: (String value) async {
                          // Handle menu item selection
                          switch (value) {
                            case 'DeliveryChallan':
                              String filepath = await generatePDF_GST(
                                Timestamp.now(),
                                widget.transaction.recieverName,
                                '',
                                '',
                                '',
                                '',
                                widget.transaction.selectedItems,
                                widget.transaction.senderName!,
                                widget.transaction.sender!,
                                'Delivery Challan',
                                PdfPageFormat.a4,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFViewerScreen(
                                    filePath: filepath,
                                  ),
                                ),
                              );
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'DeliveryChallan',
                            child: Text('Performa Invoice'),
                          ),
                        ],
                      ),
                    InkWell(
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Delete Transaction'),
                              content: Text(
                                  'Are you sure you want to delete this transaction?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    _deleteTransaction(
                                        widget.transaction.transactionId,
                                        widget.transaction.sender!);

                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Delete'),
                                )
                              ],
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel,
                            color: Colors.red.withOpacity(0.7),
                          ),
                          Text(
                            'Delete',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              if (widget.transaction.transactionType == 'credit_note')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
