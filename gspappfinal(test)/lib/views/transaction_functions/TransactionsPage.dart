import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gspappfinal/components/transactionCard.dart';
import 'package:gspappfinal/constants/AppTheme.dart';
import 'package:gspappfinal/models/TransactionsModel.dart';
import 'package:provider/provider.dart';
import 'package:gspappfinal/providers/UserProvider.dart';

class UserTransactionsPage extends StatefulWidget {
  @override
  _UserTransactionsPageState createState() => _UserTransactionsPageState();
}

class _UserTransactionsPageState extends State<UserTransactionsPage> {
  late Stream<QuerySnapshot> transactionsStream;

  @override
  void initState() {
    super.initState();

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final transactionsCollection = FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true);

    transactionsStream = transactionsCollection.snapshots();
  }

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

      double amount = transactionData['totalAmount'];
      String partyId = transactionData['partyId'];

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

      // Update the party's balance
      final partyCollection = FirebaseFirestore.instance.collection('parties');
      DocumentSnapshot partyDoc = await partyCollection.doc(partyId).get();
      if (partyDoc.exists) {
        double currentBalance =
            double.parse(partyDoc['balance'] ?? '0.0') ?? 0.0;
        String balanceType = partyDoc['balanceType'];

        // Adjust the balance based on the transaction amount
        if (transactionData['transactionType'] == balanceType) {
          currentBalance += amount.abs();
          await partyCollection.doc(partyId).update({
            'balance': currentBalance.toString(),
            'balanceType': balanceType,
          });
        } else {
          currentBalance -= amount.abs();
          if (currentBalance < 0) {
            currentBalance = currentBalance.abs();
            balanceType = balanceType == 'receive' ? 'payment' : 'receive';
          }

          await partyCollection.doc(partyId).update({
            'balance': currentBalance.toString(),
            'balanceType': balanceType,
          });
        }
      }

      // If the resulting balance is negative, change the balance type
    } catch (e) {
      print('Error deleting transaction: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: transactionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
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
    );
  }
}
