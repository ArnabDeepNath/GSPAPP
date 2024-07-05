import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  late String id;
  final String name;
  final String HSN;
  final String salePrice;
  final String purchasePrice;
  final String taxRate;
  final Timestamp creationDate;
  final String unit;
  final String img;

  ItemModel({
    required this.id,
    required this.name,
    required this.HSN,
    required this.purchasePrice,
    required this.salePrice,
    required this.taxRate,
    required this.creationDate,
    required this.unit,
    required this.img,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'HSN': HSN,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'taxRate': taxRate,
      'creationDate': creationDate,
      'unit': unit,
      'img': img,
    };
  }

  factory ItemModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data()!;
    return ItemModel(
      id: snapshot.id,
      name: data['name'],
      HSN: data['HSN'],
      purchasePrice: data['purchasePrice'],
      salePrice: data['salePrice'],
      taxRate: data['taxRate'],
      creationDate: data['creationDate'],
      unit: data['unit'],
      img: data['img'],
    );
  }
}
