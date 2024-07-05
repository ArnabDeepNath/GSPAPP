import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gspappfinal/models/ItemModel.dart';
import 'package:gspappfinal/models/PartyModel.dart';
import 'package:gspappfinal/models/TransactionsModel.dart';
import 'package:gspappfinal/models/UserModel.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference partiesCollection =
      FirebaseFirestore.instance.collection('parties');
  final CollectionReference itemsCollection =
      FirebaseFirestore.instance.collection('items');
  User? _currentUser;

  User? get currentUser => _currentUser;

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  late List<UserModel> _users = [];

  List<UserModel> get users => _users;
  final StreamController<List<String>> _partyIdsController =
      StreamController<List<String>>.broadcast();
  List<String> _partyIds = [];
  Stream<List<String>> get partyIdsStream => _partyIdsController.stream;

  Future<void> registerUser({
    required UserModel user,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      String userId = userCredential.user!.uid;
      UserModel newUser = UserModel(
        id: userId,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        password: user.password,
        phoneNumber: user.phoneNumber,
        transactions: [],
        items: [],
        parties: [],
      );

      await usersCollection.doc(userId).set({
        'contact': user.phoneNumber,
        'email': user.email,
        'id': userId,
        'first_name': user.firstName,
        'second_name': user.lastName,
        'items': [],
        'transactions': [],
        'parties': [],
      });

      _users.add(newUser);
      notifyListeners();
    } catch (e) {
      print('Error registering user: $e');
      throw e;
    }
  }

  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  Future<UserModel?> fetchUserByUID(String uid) async {
    try {
      DocumentSnapshot userDoc = await usersCollection.doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        UserModel user = UserModel(
          id: userData['id'],
          firstName: userData['first_name'],
          lastName: userData['second_name'],
          email: userData['email'],
          password: '',
          phoneNumber: userData['contact'],
          transactions: userData['transactions'],
          items: userData['items'],
          parties: userData['parties'],
        );
        _partyIds = userData['parties'].cast<String>();
        _partyIdsController.add(_partyIds);
        // print(_partyIds);
        notifyListeners();
        return user;
      }
      return null;
    } catch (e) {
      print('Error fetching user by UID: $e');
      return null;
    }
  }

  Future<void> addParty({
    required String userId,
    required PartyModel party,
  }) async {
    try {
      DocumentReference partyDoc = await partiesCollection.add({
        'name': party.name,
        'contactNumber': party.contactNumber,
        'balance': party.balance,
        'transactions': party.transactions.map((t) => t.toMap()).toList(),
        'creationDate': party.creationDate,
        'BillingAddress': party.BillingAddress,
        'EmailAddress': party.EmailAddress,
        'GSTID': party.GSTID,
        'balanceType': party.balanceType,
        'paymentType': party.paymentType,
        'GSTType': party.GSTType,
        'POS': party.POS,
        'userId': userId,
      });

      String partyId = partyDoc.id;
      party.id = partyId; // Assign the generated partyId to the party

      // Update the user's list of parties (you might want to add this field to UserModel)
      await usersCollection.doc(userId).update({
        'parties': FieldValue.arrayUnion([partyId])
      });

      notifyListeners();
    } catch (e) {
      print('Error adding party: $e');
      throw e;
    }
  }

  Future<void> addItem({
    required String userId,
    required ItemModel item,
  }) async {
    try {
      DocumentReference itemDoc = await itemsCollection.add({
        'name': item.name,
        'HSN': item.HSN,
        'salePrice': item.salePrice,
        'purchasePrice': item.purchasePrice,
        'taxRate': item.taxRate,
        'creationDate': item.creationDate,
        'unit': item.unit,
        'userId': userId,
        'img': item.img,
      });

      String itemId = itemDoc.id;

      // Update the user's list of items
      await usersCollection.doc(userId).update({
        'items': FieldValue.arrayUnion([itemId])
      });

      // Fetch the updated user data
      await fetchUserByUID(userId);

      notifyListeners();
    } catch (e) {
      print('Error adding item: $e');
      throw e;
    }
  }

  Stream<List<ItemModel>> getItemsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('items')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList());
  }

  Stream<List<TransactionModel>> getTransactionStream(String userId) {
    return FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  Future<void> addTransaction(
      UserModel? user, TransactionModel transaction) async {
    try {
      DocumentReference transactionRef = _db
          .collection('transactions')
          .doc(); // Create a new document reference
      await transactionRef.set({
        'userId': user!.id,
        'partyId': transaction.recieverId,
        'items': transaction.selectedItems,
        'totalAmount': transaction.amount,
        'balance': transaction.balance,

        'description': transaction.description,
        'timestamp': Timestamp.now(),
        'reciever': transaction.reciever,
        'sender': transaction.sender,

        'isEditable': transaction.isEditable,
        'recieverName': transaction.recieverName,
        'recieverId': transaction.recieverId,
        'transactionType': transaction.transactionType,
        'senderName': transaction.senderName,
        'selectedItems': transaction.selectedItems,
        'transactionId': transactionRef.id,
        // Add other transaction details as needed
      });

      // Update the user's transactions with the transaction ID
      await _db.collection('users').doc(user.id).update({
        'transactions': FieldValue.arrayUnion([transactionRef.id]),
      });

      // Update the party's balance
      DocumentSnapshot partyDoc =
          await _db.collection('parties').doc(transaction.recieverId).get();

      Map<String, dynamic> partyData = partyDoc.data() as Map<String, dynamic>;

      double currentBalance = double.parse(partyData['balance']) ?? 0.0;

      if (transaction.transactionType == 'payment') {
        double updatedBalance = currentBalance;
        String currentBalanceType = partyData['balanceType'] ?? '';
        String updatedBalanceType = currentBalanceType;

        if (currentBalanceType == 'payment') {
          updatedBalance += transaction.amount;
        } else {
          updatedBalance -= transaction.amount;
          updatedBalanceType =
              updatedBalance < 0 ? 'payment' : currentBalanceType;
          updatedBalance = updatedBalance.abs();
        }

        await _db.collection('parties').doc(transaction.recieverId).update({
          'balance': updatedBalance.toString(),
          'balanceType': updatedBalanceType,
        });
      } else if (transaction.transactionType == 'receive') {
        double updatedBalance = currentBalance;
        String currentBalanceType = partyData['balanceType'] ?? '';
        String updatedBalanceType = currentBalanceType;

        if (currentBalanceType == 'receive') {
          updatedBalance += transaction.amount;
          await _db.collection('parties').doc(transaction.recieverId).update({
            'balance': updatedBalance.toString(),
            'balanceType': updatedBalanceType,
          });
        } else {
          updatedBalance -= transaction.amount;
          if (updatedBalance < 0) {
            updatedBalance = updatedBalance.abs();
            updatedBalanceType =
                currentBalanceType == 'receive' ? 'payment' : 'receive';
          }
          await _db.collection('parties').doc(transaction.recieverId).update({
            'balance': updatedBalance.toString(),
            'balanceType': updatedBalanceType,
          });
        }

        await _db.collection('parties').doc(transaction.recieverId).update({
          'balance': updatedBalance.toString(),
          'balanceType': updatedBalanceType,
        });
      }

      notifyListeners();
    } catch (e) {
      print('Error adding transaction: $e');
      throw e;
    }
  }

  Stream<List<TransactionModel>> get transactionStream {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return _db
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(
                doc.data() as DocumentSnapshot<Object?>))
            .toList());
  }

  Future<void> fetchCurrentUser() async {
    // Assuming you are using FirebaseAuth to get the current user
    _currentUser = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  void dispose() {
    _partyIdsController.close();
  }
}
