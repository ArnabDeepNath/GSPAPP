import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gspappfinal/models/TransactionsModel.dart';

class PartyModel {
  late String id;
  final String name;
  final String contactNumber;
  final Timestamp creationDate;
  final String GSTID;
  final String BillingAddress;
  final String EmailAddress;
  final String paymentType;
  final String balanceType;
  var balance;
  List<TransactionModel> transactions;
  final String GSTType;
  final String POS;

  PartyModel({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.balance,
    required this.transactions,
    required this.creationDate,
    required this.BillingAddress,
    required this.EmailAddress,
    required this.GSTID,
    required this.balanceType,
    required this.paymentType,
    required this.GSTType,
    required this.POS,
  });

  // Convert PartyModel object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'contactNumber': contactNumber,
      'creationDate': creationDate,
      'GSTID': GSTID,
      'BillingAddress': BillingAddress,
      'EmailAddress': EmailAddress,
      'paymentType': paymentType,
      'balanceType': balanceType,
      'balance': balance,
      'transactions': transactions.map((t) => t.toMap()).toList(),
      'GSTType': GSTType,
      'POS': POS,
    };
  }

  // Create PartyModel object from Firestore data
  factory PartyModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data()!;
    return PartyModel(
      id: snapshot.id,
      name: data['name'],
      contactNumber: data['contactNumber'],
      creationDate: data['creationDate'],
      GSTID: data['GSTID'],
      BillingAddress: data['BillingAddress'],
      EmailAddress: data['EmailAddress'],
      paymentType: data['paymentType'],
      balanceType: data['balanceType'],
      balance: data['balance'],
      transactions: (data['transactions'] as List<dynamic>)
          .map((t) => TransactionModel.fromFirestore(t))
          .toList(),
      GSTType: data['GSTType'],
      POS: data['POS'],
    );
  }
}
