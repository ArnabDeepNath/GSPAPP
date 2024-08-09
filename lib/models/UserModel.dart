import 'package:gspappfinal/models/ItemModel.dart';
import 'package:gspappfinal/models/PartyModel.dart';
import 'package:gspappfinal/models/TransactionsModel.dart';

class UserModel {
  late String id;
  late String firstName;
  late String lastName;
  late String email;
  late String password;
  late String phoneNumber;

  late List<dynamic> transactions;
  late List<dynamic> items;
  late List<dynamic> parties;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.transactions,
    required this.items,
    required this.parties,
  });
}
