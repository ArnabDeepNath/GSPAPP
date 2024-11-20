import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gspappfinal/models/ItemModel.dart';

class ItemsProvider with ChangeNotifier {
  late List<ItemModel> _items = [];

  List<ItemModel> get items => _items;

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> addItem(ItemModel item) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference itemDoc =
          await FirebaseFirestore.instance.collection('items').add({
        'id': '',
        'userId': userId,
        'name': item.name,
        'description': item.unit,
        // Add other item properties as needed
      });

      String itemId = itemDoc.id;
      item.id = itemId; // Assign the generated itemId to the item

      // Update the user's list of items (you might want to add this field to UserModel)
      DocumentSnapshot userSnapshot = await usersCollection.doc(userId).get();
      List<String> userItems = List<String>.from(
          (userSnapshot.data() as Map<String, dynamic>)['items'] ?? []);
      userItems.add(itemId);

      await usersCollection.doc(userId).update({
        'items': userItems,
      });

      print('Item added successfully');
      print('Job Done'); // Ensure that this is reached
      notifyListeners();
    } catch (e) {
      print('Error adding item: $e');
      throw e; // Rethrow the error to handle it in the UI if needed
    }
  }

  Future<void> fetchItemsByUserId() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('userId', isEqualTo: userId)
          .get();

      _items =
          snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching items: $e');
    }
  }
}
