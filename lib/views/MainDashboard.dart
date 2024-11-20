import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

class MainDashboard extends StatefulWidget {
  final String userID;
  const MainDashboard({Key? key, required this.userID}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      key: _scaffoldKey,
      backgroundColor: AppColors.secondaryColor,
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              color: AppColors.primaryColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  const CircleAvatar(
                    radius: 45,
                    backgroundImage:
                        NetworkImage('https://i.pravatar.cc/150?img=3'),
                  ),
                  const SizedBox(width: 10),
                  Text(
                      '${_currentUser.firstName} \n${_currentUser.lastName}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 25)),
                ],
              ),
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
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(
            Icons.menu,
            size: 25,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Hello ${_currentUser.firstName}',
          style: AppFonts.Header1().copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_on,
                color: Colors.white,
              ))
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.secondaryColor,
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Row(
              children: [
                Expanded(child: buildCustomTab('Dashboard', 0)),
                Expanded(child: buildCustomTab('Items', 1)),
                Expanded(child: buildCustomTab('Transactions', 2)),
              ],
            ),
          ),
          const SizedBox(height: 10,),
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

  Widget buildCustomTab(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? Colors.transparent
              : AppColors.primaryColor.withOpacity(0.1),
          border: Border(
            left: const BorderSide(
              color: AppColors.primaryColor,
              width: 1,
            ),
            right: const BorderSide(
              color: AppColors.primaryColor,
              width: 1,
            ),
            bottom: BorderSide(
              color: _selectedIndex == index
                  ? Colors.transparent
                  : AppColors.primaryColor,
              width: 2, // Highlight the selected tab
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _selectedIndex == index
                ? AppColors.primaryColor
                : Colors.black,
            fontWeight: _selectedIndex == index
                ? FontWeight.w600
                : FontWeight.w400,
            fontSize: 14, // Consistent font size
          ),
        ),
      ),
    );
  }



  Widget _buildItemsPage(UserModel user) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return StreamBuilder<List<ItemModel>>(
          stream: userProvider.getItemsStream(user.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
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
          stream: userProvider.getTransactionStream(user.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
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
}
