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
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Your Parties',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          PartyModel party = parties[index];
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.18,
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
                                      party.contactNumber,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Rs. ${party.balance}',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                party.balanceType == 'receive'
                                                    ? Colors.red
                                                    : Colors.green,
                                          ),
                                        ),
                                        Text(
                                          party.balanceType == 'receive'
                                              ? 'You will pay'
                                              : 'You will receive',
                                          style: GoogleFonts.inter(
                                            color:
                                                party.balanceType == 'receive'
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
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          InkWell(
                                            onTap: () {},
                                            child: Column(
                                              children: [
                                                Icon(Icons.call),
                                                Text(
                                                  'Send Notification',
                                                  style: AppFonts.Subtitle2(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const VerticalDivider(
                                            color: Colors.grey,
                                            thickness: 0.8,
                                            indent: 5,
                                            endIndent: 5,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                        'Confirm Deletion'),
                                                    content: Text(
                                                        'Are you sure you want to delete this party?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          await _deleteParty(
                                                            party.id,
                                                            currentUser!.id,
                                                          );
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('Delete'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: Column(
                                              children: [
                                                Icon(Icons.cancel),
                                                Text(
                                                  'Delete Party',
                                                  style: AppFonts.Subtitle2(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
