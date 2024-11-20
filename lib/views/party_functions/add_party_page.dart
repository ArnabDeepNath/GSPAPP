import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspappfinal/constants/AppColor.dart';
import 'package:gspappfinal/models/UserModel.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController partyNameController = TextEditingController();
  final TextEditingController openingBalanceController =
      TextEditingController();
  final TextEditingController asOfDateController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController billingAddressController =
      TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController gstIdController = TextEditingController();

  // Dropdown Values
  String balanceType = "To Pay";
  String gstType = "Unregistered/Consumer";
  String placeOfSupply = "18-Assam";
  String rcn = "Yes";

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        asOfDateController.text = pickedDate.toString().split(' ')[0];
      });
    }
  }

  String? validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  void clearFields() {
    partyNameController.clear();
    openingBalanceController.clear();
    asOfDateController.clear();
    contactNumberController.clear();
    billingAddressController.clear();
    emailAddressController.clear();
    gstIdController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context); // Go back to the previous screen
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: const Icon(
              Icons.arrow_back, // Replace with your desired icon
              color: Colors.white, // Customize the icon color
              size: 24, // Customize the icon size
            ),
          ),
        ),
        title: const Text(
          'Add New Party',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Party Name',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: partyNameController,
                  decoration: const InputDecoration(
                    labelText: "Party Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: validateField,
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Opening Balance",
                            style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: openingBalanceController,
                            decoration: const InputDecoration(
                              labelText: "Enter Opening Balance",
                              border: OutlineInputBorder(),
                            ),
                            validator: validateField,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "As of Date",
                            style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: asOfDateController,
                            decoration: const InputDecoration(
                              labelText: "Select Date",
                              border: OutlineInputBorder(),
                            ),
                            onTap: () => _selectDate(context),
                            readOnly: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16.0),
                Text("Balance Type", style: TextStyle(fontSize: 16.0)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text("To Pay"),
                        value: "To Pay",
                        groupValue: balanceType,
                        onChanged: (value) {
                          setState(() {
                            balanceType = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text("To Receive"),
                        value: "To Receive",
                        groupValue: balanceType,
                        onChanged: (value) {
                          setState(() {
                            balanceType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Contact Number",
                      style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: contactNumberController,
                      decoration: const InputDecoration(
                        labelText: "Contact Number",
                        border: OutlineInputBorder(),
                      ),
                      validator: validateField,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Text("RCN", style: TextStyle(fontSize: 16.0)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text("Yes"),
                        value: "Yes",
                        groupValue: rcn,
                        onChanged: (value) {
                          setState(() {
                            rcn = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text("No"),
                        value: "No",
                        groupValue: rcn,
                        onChanged: (value) {
                          setState(() {
                            rcn = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,child: Divider(color: Colors.blue.shade200,),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Addresses',
                      style: GoogleFonts.inter(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Billing Address",
                          style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          controller: billingAddressController,
                          decoration: const InputDecoration(
                            labelText: "Billing Address",
                            border: OutlineInputBorder(),
                          ),
                          validator: validateField,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email Address",
                          style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          controller: emailAddressController,
                          decoration: const InputDecoration(
                            labelText: "Email Address",
                            border: OutlineInputBorder(),
                          ),
                          validator: validateField,
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(
                  height: 60,child: Divider(color: Colors.blue.shade200,),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GST Details',
                      style: GoogleFonts.inter(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "GST Type",
                          style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10.0),
                        DropdownButtonFormField<String>(
                          value: gstType,
                          decoration: const InputDecoration(
                            labelText: "GST Type",
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            "Unregistered/Consumer",
                            "Registered - Single",
                            "Registered - Composite"
                          ]
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              gstType = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "State",
                          style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10.0),
                        DropdownButtonFormField<String>(
                          value: placeOfSupply,
                          decoration: const InputDecoration(
                            labelText: "Place of Supply",
                            border: OutlineInputBorder(),
                          ),
                          items: ["18-Assam", "27-Maharashtra", "29-Karnataka"]
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              placeOfSupply = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 44,
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primaryColor)),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          // Add party logic
                          clearFields();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Party added successfully")),
                          );
                        }
                      },
                      child: Container(
                        height: 44,
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child:Text(
                            'Add Item',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
