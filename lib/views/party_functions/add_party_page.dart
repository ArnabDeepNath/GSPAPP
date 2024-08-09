import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspappfinal/components/SlideButton.dart';
import 'package:gspappfinal/components/TextFormField.dart';
import 'package:gspappfinal/components/dialogBox.dart';
import 'package:gspappfinal/constants/AppColor.dart';
import 'package:gspappfinal/constants/AppTheme.dart';

import 'package:gspappfinal/models/PartyModel.dart';
import 'package:gspappfinal/models/TransactionsModel.dart';
import 'package:gspappfinal/models/UserModel.dart';
import 'package:gspappfinal/providers/userProvider.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddPartyScreen extends StatefulWidget {
  UserModel? user;
  AddPartyScreen({
    super.key,
    required this.user,
  });

  @override
  State<AddPartyScreen> createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends State<AddPartyScreen>
    with TickerProviderStateMixin {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Credentials
  TextEditingController PartyNameController = TextEditingController();
  TextEditingController PartyBalanceController = TextEditingController();
  TextEditingController PartyContactController = TextEditingController();
  TextEditingController PartyGSTController = TextEditingController();
  // Dropdown Box ->
  TextEditingController PartyCreationController = TextEditingController();
  TextEditingController PartyBillingAddress = TextEditingController();
  TextEditingController PartyEmailAddress = TextEditingController();
  TextEditingController PartyState = TextEditingController();

  // Payment Mode Initiation
  late String paymentType = 'cash';
  late String BalanceType = 'pay';

  // GST Options
  String _selectedOption = 'Unregistered/Consumer';

  String? _selectedOptionRCN = 'Yes';

  // Place of Supply Options
  String _selectedState = '18-Assam';

  // Party Controller Intiliasation

  // Date Function
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        // Update the date in the partyCreation TextEditingController
        PartyCreationController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Define a controller for the TabBar
  late TabController _tabController;
  bool userTyping = false; // Added variable to track user typing

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    PartyBalanceController.text = '0.0';
  }

  // Clear Function
  void clear() {
    PartyBalanceController.clear();
    PartyContactController.clear();
    PartyNameController.clear();
    PartyBillingAddress.clear();
    PartyEmailAddress.clear();
    PartyGSTController.clear();
    PartyState.clear();
    PartyCreationController.clear();
  }

  // Validator

  String? nonEmptyValidator(String? value) {
    if (value != null && value.isNotEmpty) {
      return null; // Field is not empty, so it's valid.
    }

    // Field is empty, so return an error message.
    return 'This field cannot be empty';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Add Party',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          SlideButton(
            choice1: 'Cheque',
            choice2: 'Cash',
            onSelectionChanged: (selected) {
              print('Selected: $selected');
            },
            Colors: Colors.green,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormFieldCustom(
                validator: nonEmptyValidator,
                label: 'Party Name',
                controller: PartyNameController,
                obscureText: false,
                onChange: (text) {
                  // Set userTyping to true when the user starts typing
                  setState(() {
                    userTyping = true;
                  });
                  if (_tabController.indexIsChanging) {
                    _tabController.animateTo(0);
                  }
                },
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3), // Shadow color
                            // Shadow color
                            offset: const Offset(0, 2), // Offset of the shadow
                            blurRadius: 4, // Blur radius of the shadow
                            spreadRadius: 1, // Spread radius of the shadow
                          ),
                        ],
                      ),
                      width: 155,
                      child: TextFormField(
                        onChanged: (text) {
                          // Set userTyping to true when the user starts typing
                          setState(() {
                            userTyping = true;
                          });
                          if (_tabController.indexIsChanging) {
                            _tabController.animateTo(0);
                          }
                        },
                        controller: PartyBalanceController,
                        decoration: InputDecoration(
                          labelText: 'Opening Balance*',
                          labelStyle: GoogleFonts.inter(
                            color: AppColors.primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3), // Shadow color
                            // Shadow color
                            offset: const Offset(0, 2), // Offset of the shadow
                            blurRadius: 4, // Blur radius of the shadow
                            spreadRadius: 1, // Spread radius of the shadow
                          ),
                        ],
                      ),
                      width: 155,
                      child: TextFormField(
                        controller: PartyCreationController,
                        onTap: () {
                          // Show date picker when the user taps on the TextFormField
                          _selectDate(context);
                        },
                        decoration: InputDecoration(
                          labelText: 'As of Date*',
                          labelStyle: GoogleFonts.inter(
                            color: AppColors.primaryColor,
                          ),
                          // Set the border color here
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SlideButton(
                choice1: 'To Pay',
                choice2: 'To Recieve',
                onSelectionChanged: (selected) {
                  if (selected == 'To Pay') {
                    setState(
                      () {
                        BalanceType = 'pay';
                      },
                    );
                  } else if (selected == 'To Recieve') {
                    setState(() {
                      BalanceType = 'recieve';
                    });
                  }
                  print(BalanceType);
                },
                Colors: Colors.red,
              ),
              TextFormFieldCustom(
                validator: nonEmptyValidator,
                label: 'Contact Number',
                controller: PartyContactController,
                obscureText: false,
                onChange: (text) {
                  // Set userTyping to true when the user starts typing
                  setState(() {
                    userTyping = true;
                  });
                  if (_tabController.indexIsChanging) {
                    _tabController.animateTo(0);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RCN:',
                      style: AppFonts.Subtitle(),
                    ),
                    DropdownButton<String>(
                      hint: Text('RCN'),
                      value: _selectedOptionRCN,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedOptionRCN = value;
                        });
                      },
                      items: [
                        'Yes',
                        'No',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Add a placeholder for the TabBar and TabBarView
              Visibility(
                visible: userTyping,
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: 'Address'),
                        Tab(text: 'GST Details'),
                      ],
                    ),
                    Container(
                      height: 200, // Set the desired height
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Add widgets for the first tab here
                          Column(
                            children: [
                              TextFormFieldCustom(
                                validator: nonEmptyValidator,
                                label: 'Billing Address',
                                controller: PartyBillingAddress,
                                obscureText: false,
                                onChange: (text) {
                                  // Set userTyping to true when the user starts typing
                                },
                              ),
                              TextFormFieldCustom(
                                validator: nonEmptyValidator,
                                obscureText: false,
                                label: 'Email Address',
                                controller: PartyEmailAddress,
                                onChange: (text) {
                                  // Set userTyping to true when the user starts typing
                                },
                              ),
                            ],
                          ),
                          // Add widgets for the second tab here
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey
                                            .withOpacity(0.3), // Shadow color
                                        // Shadow color
                                        offset: const Offset(
                                            0, 2), // Offset of the shadow
                                        blurRadius:
                                            4, // Blur radius of the shadow
                                        spreadRadius:
                                            1, // Spread radius of the shadow
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DropdownButton<String>(
                                      underline: Container(),
                                      hint: const Text('GST Type'),
                                      value: _selectedOption,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedOption = newValue!;
                                        });
                                      },
                                      items: <String>[
                                        'Unregistered/Consumer',
                                        'Registered - Single',
                                        'Registered - Composite',
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey
                                            .withOpacity(0.3), // Shadow color
                                        // Shadow color
                                        offset: const Offset(
                                            0, 2), // Offset of the shadow
                                        blurRadius:
                                            4, // Blur radius of the shadow
                                        spreadRadius:
                                            1, // Spread radius of the shadow
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DropdownButton<String>(
                                      hint: const Text('Place of Supply'),
                                      value: _selectedState,
                                      underline: Container(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedState = newValue!;
                                        });
                                      },
                                      items: <String>[
                                        '01-Jammu & Kashmir',
                                        '02-Himachal Pradesh',
                                        '03-Punjab',
                                        '04-Chandigarh',
                                        '05-Uttarakhand',
                                        '06-Haryana',
                                        '07-Delhi',
                                        '08-Rajasthan',
                                        '09-Uttar Pradesh',
                                        '10-Bihar',
                                        '11-Sikkim',
                                        '12-Arunachal Pradesh',
                                        '13-Nagaland',
                                        '14-Manipur',
                                        '15-Mizoram',
                                        '16-Tripura',
                                        '17-Meghalaya',
                                        '18-Assam',
                                        '19-West Bengal',
                                        '20-Jharkhand',
                                        '21-Odisha',
                                        '22-Chhattisgarh',
                                        '23-Madhya Pradesh',
                                        '24-Gujarat',
                                        '25-Daman & Diu',
                                        '26-Dadra & Nagar Haveli & Daman & Diu',
                                        '27-Maharashtra',
                                        '29-Karnataka',
                                        '30-Goa',
                                        '31-Lakshdweep',
                                        '32-Kerala',
                                        '33-Tamil Nadu',
                                        '34-Puducherry',
                                        '35-Andaman & Nicobar Islands',
                                        '36-Telangana',
                                        '37-Andhra Pradesh',
                                        '38-Ladakh',
                                        '97-Other Territory',
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
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
              SizedBox(height: 22),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // The form is valid, proceed to create a new party.
                    final userProvider =
                        Provider.of<UserProvider>(context, listen: false);

                    final party = PartyModel(
                      id: '',
                      name: PartyNameController.text,
                      contactNumber: PartyContactController.text,
                      balance: PartyBalanceController.text ?? 0.0,
                      transactions: [],
                      creationDate: Timestamp.now(),
                      BillingAddress: PartyBillingAddress.text,
                      EmailAddress: PartyEmailAddress.text,
                      GSTID: PartyGSTController.text ?? '',
                      balanceType: BalanceType,
                      paymentType: paymentType,
                      GSTType: '',
                      POS: _selectedState,
                    );

                    userProvider.addParty(
                      party: party,
                      userId: widget.user!.id,
                    );
                    clear();
                    showSimpleDialog(context, 'Party Have been Added');
                  }
                },
                child: Text('Add New Party'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
