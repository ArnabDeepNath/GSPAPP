import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gspappfinal/models/PartyModel.dart';

class PartyProvider extends ChangeNotifier {
  late List<PartyModel> _items;
  late StreamController<List<PartyModel>> _streamController;

  Stream<List<PartyModel>> get partiesStream => _streamController.stream;
  List<PartyModel> get items => _items;

  PartyProvider() {
    _items = [];
    _streamController = StreamController<List<PartyModel>>.broadcast();
  }

  void fetchParties(String userId) {
    FirebaseFirestore.instance
        .collection('parties')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _items =
          snapshot.docs.map((doc) => PartyModel.fromFirestore(doc)).toList();
      _streamController.add(_items);
    });
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}
