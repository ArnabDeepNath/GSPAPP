import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final double amount;
  final String description;
  final Timestamp timestamp;
  final String? sender;
  final String? reciever;
  final bool isEditable;
  final double balance;
  final String recieverName;
  final String recieverId;
  final String transactionType;
  final String transactionId;
  final String? senderName;
  final List<dynamic> selectedItems;

  TransactionModel({
    required this.amount,
    required this.description,
    required this.timestamp,
    required this.reciever,
    required this.sender,
    required this.balance,
    required this.isEditable,
    required this.recieverName,
    required this.recieverId,
    required this.transactionType,
    required this.transactionId,
    required this.senderName,
    required this.selectedItems,
  });

  // Create a method to convert the transaction data to a map
  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'description': description,
      'timestamp': timestamp,
      'sender': sender,
      'receiver': reciever,
      'balance': balance,
      'isEditable': isEditable,
      'receiverName': recieverName,
      'receiverId': recieverId,
      'transactionType': transactionType,
      'transactionId': transactionId,
      'senderName': senderName,
      'selectedItems': selectedItems,
    };
  }

  // Create a factory method to create a transaction object from a map
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      amount: data['totalAmount'] ?? 0.0,
      description: data['description'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      sender: data['sender'] ?? '',
      reciever: data['receiver'] ?? '',
      balance: data['balance'] ?? 0.0,
      isEditable: data['isEditable'] ?? false,
      recieverName: data['recieverName'] ?? '',
      recieverId: data['receiverId'] ?? '',
      transactionType: data['transactionType'] ?? '',
      transactionId: data['transactionId'] ?? '',
      senderName: data['senderName'] ?? '',
      selectedItems: data['selectedItems'] ?? [],
    );
  }
}
