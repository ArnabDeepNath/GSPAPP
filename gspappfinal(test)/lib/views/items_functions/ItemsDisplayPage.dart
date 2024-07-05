import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspappfinal/constants/AppColor.dart';
import 'package:gspappfinal/constants/AppTheme.dart';
import 'package:gspappfinal/models/ItemModel.dart';
import 'package:gspappfinal/models/UserModel.dart';
import 'package:gspappfinal/providers/itemsProvider.dart';
import 'package:gspappfinal/views/items_functions/AddItemsPage.dart';
import 'package:provider/provider.dart';

class ItemsDisplayPage extends StatefulWidget {
  final UserModel user;
  const ItemsDisplayPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ItemsDisplayPage> createState() => _ItemsDisplayPageState();
}

class _ItemsDisplayPageState extends State<ItemsDisplayPage> {
  late Stream<QuerySnapshot> itemsStream;

  @override
  void initState() {
    super.initState();

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final itemsCollection =
        FirebaseFirestore.instance.collection('items').where(
              'userId',
              isEqualTo: userId,
            );

    itemsStream = itemsCollection.snapshots();
  }

  void _deleteItem(String itemId) async {
    final itemsCollection = FirebaseFirestore.instance.collection('items');

    // Get the item document
    final itemDoc = await itemsCollection.doc(itemId).get();

    // Check if the item exists
    if (itemDoc.exists) {
      // Get the userId from the item document
      final userId = itemDoc['userId'];

      // Delete the item
      await itemsCollection.doc(itemId).delete();

      // Update the user's items list
      final userCollection = FirebaseFirestore.instance.collection('users');
      final userDoc = await userCollection.doc(userId).get();
      if (userDoc.exists) {
        final List<dynamic> items = userDoc['items'];
        items.remove(itemId);
        await userCollection.doc(userId).update({'items': items});
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog(String itemId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this item?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteItem(itemId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemsProvider>(
      builder: (context, itemProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.secondaryColor,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: itemsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    // Filter the items that belong to the current user
                    List<DocumentSnapshot> userItems = snapshot.data!.docs
                        .where((item) => item['userId'] == widget.user.id)
                        .toList();

                    return GridView.builder(
                      padding: const EdgeInsets.all(10.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                      ),
                      itemCount: userItems.length + 1,
                      itemBuilder: (context, index) {
                        if (index == userItems.length) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddItemsPage(
                                    user: widget.user,
                                  ),
                                ),
                              );
                            },
                            child: Container(
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
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  size: 50,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          );
                        } else {
                          var item =
                              userItems[index].data() as Map<String, dynamic>;
                          return Container(
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
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ListTile(
                                    subtitle: Center(
                                      child: Text(
                                        item['name'],
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    title: CircleAvatar(
                                      radius: 40,
                                      backgroundImage: NetworkImage(
                                        item['img'],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        InkWell(
                                          onTap: () {},
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                color: Colors.black38,
                                              ),
                                              Text(
                                                'Edit Item',
                                                style: AppFonts.Subtitle2(),
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            _showDeleteConfirmationDialog(
                                                userItems[index].id);
                                          },
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.cancel,
                                                color: Colors.red.shade300,
                                              ),
                                              Text(
                                                'Delete Item',
                                                style: AppFonts.Subtitle2(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}