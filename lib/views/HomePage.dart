import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspappfinal/constants/AppColor.dart';
import 'package:gspappfinal/constants/AppTheme.dart';
import 'package:gspappfinal/models/PartyModel.dart';
import 'package:gspappfinal/models/UserModel.dart';
import 'package:gspappfinal/providers/partyProvider.dart';
import 'package:gspappfinal/providers/userProvider.dart';
import 'package:gspappfinal/views/party_functions/PartyView.dart';
import 'package:gspappfinal/views/party_functions/add_party_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      currentUser = await userProvider.fetchUserByUID(userId);
      if (currentUser != null) {
        _fetchParties();
      }
    }
  }

  void _fetchParties() {
    final partyProvider = Provider.of<PartyProvider>(context, listen: false);
    partyProvider.fetchParties(currentUser!.id);
  }

  Future<void> _deleteParty(String partyId, String userId) async {
    try {
      final transactionsCollection =
          FirebaseFirestore.instance.collection('transactions');
      final partyCollection = FirebaseFirestore.instance.collection('parties');
      final userCollection = FirebaseFirestore.instance.collection('users');

      // Check if there are any transactions associated with the party
      QuerySnapshot transactions = await transactionsCollection
          .where('partyId', isEqualTo: partyId)
          .get();
      if (transactions.docs.isNotEmpty) {
        // Show error message if transactions are associated with the party
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot delete party with existing transactions'),
          ),
        );
        return;
      }

      // Delete the party
      await partyCollection.doc(partyId).delete();

      // Remove the party ID from the user's parties list
      DocumentSnapshot userDoc = await userCollection.doc(userId).get();
      if (userDoc.exists) {
        List<dynamic> parties = userDoc['parties'];
        parties.remove(partyId);
        await userCollection.doc(userId).update({'parties': parties});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Party deleted successfully')),
      );
    } catch (e) {
      print('Error deleting party: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting party')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: Consumer<PartyProvider>(
        builder: (context, partyProvider, child) {
          return StreamBuilder<List<PartyModel>>(
            stream: partyProvider.partiesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No parties',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                    ),
                  ),
                );
              } else {
                final parties = snapshot.data!;
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
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
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Text(
                                          'FY 24-25',
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.black,
                                      )
                                    ],
                                  ),
                                  Divider(color: Colors.blue.shade100),
                                  // Sale and Purchase Row
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              '₹ 2,000',
                                              style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Sale',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: 40,
                                          width: 1,
                                          color: Colors.blue.shade100,
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              '₹ 2,000',
                                              style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Purchase',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Existing Row for "Your Parties" title
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Text(
                                  'Your Parties',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AddPartyScreen(
                                          user: currentUser,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add, color: Colors.white),
                                      SizedBox(width: 2),
                                      Text(
                                        'Add Party',
                                        style: TextStyle(color: Colors.white),
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
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          PartyModel party = parties[index];
                          DateTime dateTime = (party.creationDate).toDate();
                          String formattedDate =
                              DateFormat('d MMM yyyy').format(dateTime);
                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ListTile(
                                        title: Text(
                                          party.name,
                                          style: AppFonts.Subtitle(),
                                        ),
                                        subtitle: Text(
                                          formattedDate.toString(),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey),
                                        ),
                                        trailing: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '₹ ${party.balance}',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: party.balanceType ==
                                                        'receive'
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),
                                            Text(
                                              party.balanceType == 'receive'
                                                  ? 'You will pay'
                                                  : 'You will receive',
                                              style: GoogleFonts.inter(
                                                color: party.balanceType ==
                                                        'receive'
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PartyDetailsPage(
                                                party: party,
                                                user: currentUser,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 13,
                                right: 5,
                                child: IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () {
                                    // Define your menu options here
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Wrap(
                                          children: [
                                            ListTile(
                                              leading: Icon(Icons.edit),
                                              title: Text('Edit'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                // Handle edit option here
                                              },
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.delete),
                                              title: Text('Delete'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                // Handle delete option here
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                        childCount: parties.length,
                      ),
                    ),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }
}
