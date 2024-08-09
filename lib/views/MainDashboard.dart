import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gspappfinal/components/drawerComponent.dart';
import 'package:gspappfinal/constants/AppColor.dart';
import 'package:gspappfinal/constants/AppTheme.dart';
import 'package:gspappfinal/auth/LoginPage.dart';
import 'package:gspappfinal/models/ItemModel.dart';
import 'package:gspappfinal/models/TransactionsModel.dart';
import 'package:gspappfinal/models/UserModel.dart';
import 'package:gspappfinal/providers/userProvider.dart';
import 'package:gspappfinal/views/party_functions/add_party_page.dart';
import 'package:gspappfinal/views/items_functions/EmptyItemsPage.dart';
import 'package:gspappfinal/views/HomePage.dart';
import 'package:gspappfinal/views/items_functions/ItemsDisplayPage.dart';
import 'package:gspappfinal/views/report_functions/report_fucntion_1.dart';
import 'package:gspappfinal/views/transaction_functions/TransactionsPage.dart';
import 'package:provider/provider.dart';

class MainDashboard extends StatefulWidget {
  final String userID;
  const MainDashboard({Key? key, required this.userID}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  late UserModel _currentUser = UserModel(
    id: '',
    email: '',
    firstName: '',
    lastName: '',
    transactions: [],
    items: [],
    parties: [],
    password: '',
    phoneNumber: '',
  );

  @override
  void initState() {
    fetchCurrentUser();
    super.initState();
    _pages = [
      const HomePage(),
      _buildItemsPage(_currentUser),
      _buildTransactionPage(_currentUser),
    ];
  }

  late Stream<QuerySnapshot> itemsStream;

  Future<void> fetchCurrentUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    UserModel? user = await userProvider.fetchUserByUID(widget.userID);
    if (user != null) {
      setState(() {
        _currentUser = user;
        _pages[1] = _buildItemsPage(user);
        _pages[2] = _buildTransactionPage(user);
      });
    }
  }

  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } catch (e) {
      // Handle sign-out errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundImage: NetworkImage(''),
              ),
              Column(
                children: [
                  Text(
                    '${_currentUser.firstName}',
                    style: AppFonts.Subtitle2(),
                  ),
                  const Divider(
                    thickness: 0.8,
                    endIndent: 20,
                    indent: 10,
                  ),
                  drawerComponent(
                    name: 'Home',
                    icon: Icons.home,
                    onChanged: () {},
                  ),
                  drawerComponent(
                    name: 'Transactions',
                    icon: Icons.compare_arrows,
                    onChanged: () {},
                  ),
                  drawerComponent(
                    name: 'Reports',
                    icon: Icons.note,
                    onChanged: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportFunction(
                            user: _currentUser,
                          ),
                        ),
                      );
                    },
                  ),
                  drawerComponent(
                    name: 'Items',
                    icon: Icons.shopping_bag,
                    onChanged: () {},
                  ),
                  drawerComponent(
                    name: 'Settings',
                    icon: Icons.settings,
                    onChanged: () {},
                  ),
                  drawerComponent(
                    name: 'Parties',
                    icon: Icons.person_search,
                    onChanged: () {},
                  ),
                  drawerComponent(
                    name: 'About Us',
                    icon: Icons.info,
                    onChanged: () {},
                  ),
                  drawerComponent(
                    name: 'Sign out',
                    icon: Icons.logout,
                    onChanged: () {
                      signOut();
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        title: Text(
          'Hello ${_currentUser.firstName}',
          style: AppFonts.Header1(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: const Text(
                'Add Party',
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddPartyScreen(
                      user: _currentUser,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildCustomButton('Dashboard', 0),
                  buildCustomButton('Items', 1),
                  buildCustomButton('Transactions', 2),
                ],
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCustomButton(String text, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _selectedIndex == index
                ? AppColors.primaryColor
                : Colors.black.withOpacity(0.2),
          ),
          color: _selectedIndex == index
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _selectedIndex == index
                ? AppColors.primaryColor
                : Colors.black.withOpacity(0.2),
          ),
        ),
      ),
    );
  }

  Widget _buildItemsPage(UserModel user) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return StreamBuilder<List<ItemModel>>(
          stream: userProvider.getItemsStream(
              user.id), // Assuming you have a method to get the items stream
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return emptyItemsPage(user: user);
            } else {
              user.items = snapshot.data!;
              return ItemsDisplayPage(user: user);
            }
          },
        );
      },
    );
  }

  Widget _buildTransactionPage(UserModel user) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return StreamBuilder<List<TransactionModel>>(
          stream: userProvider.getTransactionStream(
              user.id), // Assuming you have a method to get the items stream
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No Transactions',
                  style: AppFonts.Header1().copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              );
            } else {
              user.items = snapshot.data!;
              return UserTransactionsPage();
            }
          },
        );
      },
    );
  }

  Future<void> fetchUserItems(UserModel user) async {
    final itemsCollection =
        FirebaseFirestore.instance.collection('items').where(
              'userId',
              isEqualTo: user.id,
            );
    itemsStream = itemsCollection.snapshots();
  }
}
