import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gspappfinal/constants/AppColor.dart';
import 'package:gspappfinal/constants/AppTheme.dart';
import 'package:gspappfinal/providers/userProvider.dart';
import 'package:gspappfinal/utils/customPDFUtil.dart';
import 'package:gspappfinal/views/report_functions/report_fucntion_1.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';

class ReportGeneration extends StatefulWidget {
  const ReportGeneration({super.key});

  @override
  State<ReportGeneration> createState() => _ReportGenerationState();
}

class _ReportGenerationState extends State<ReportGeneration> {
  String? _selectedOption;
  List<Map<String, dynamic>> transactions = [];
  int totalSales = 0;
  int totalExpense = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTotalSalesAndExpenses();
    });
  }

  Future<void> fetchTotalSalesAndExpenses() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.currentUser?.uid;

    if (userId != null) {
      final salesSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('transactionType', isEqualTo: 'receive')
          .get();

      final expenseSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('transactionType', isEqualTo: 'payment')
          .get();

      setState(() {
        totalSales = salesSnapshot.docs.length;
        totalExpense = expenseSnapshot.docs.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final currentUser = userProvider.currentUser;
        return Scaffold(
          appBar: AppBar(),
          backgroundColor: AppColors.secondaryColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Sales',
                            style: AppFonts.Header1(),
                          ),
                          Text(
                            '$totalSales',
                            style: AppFonts.Subtitle2(),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Expense',
                            style: AppFonts.Header1(),
                          ),
                          Text(
                            '$totalExpense',
                            style: AppFonts.Subtitle2(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales Transactions',
                        style: AppFonts.Header1(),
                      ),
                      _buildTransactionList('receive'),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Purchase Transactions',
                        style: AppFonts.Header1(),
                      ),
                      _buildTransactionList('payment'),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Items',
                        style: AppFonts.Header1(),
                      ),
                      Text(
                        '',
                        style: AppFonts.Subtitle2(),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownButton<String>(
                        hint: Text('Generate Report'),
                        value: _selectedOption,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedOption = value;
                          });
                        },
                        items: [
                          'Sale Report',
                          'Purchase Report',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_selectedOption == 'Sale Report' ||
                              _selectedOption == 'Purchase Report') {
                            await fetchTransactions(
                                userProvider.currentUser!.uid,
                                _selectedOption!);
                            final pdfLink = await customPDFGeneration(
                              Timestamp.now(),
                              currentUser!.displayName,
                              '',
                              '',
                              '',
                              '',
                              transactions,
                              currentUser!.displayName,
                              currentUser!.uid,
                              '${_selectedOption}',
                              PdfPageFormat.a4,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PDFViewerScreen(filePath: pdfLink),
                              ),
                            );
                          }
                        },
                        child: Text('Generate PDF'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchTransactions(String userId, String reportType) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('transactionType', whereIn: ['receive', 'payment']).get();

    final filteredTransactions = querySnapshot.docs
        .where((doc) => reportType == 'Sale Report'
            ? doc['transactionType'] == 'receive'
            : doc['transactionType'] == 'payment')
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    setState(() {
      transactions = filteredTransactions;
    });

    print(transactions);
  }

  Widget _buildTransactionList(String transactionType) {
    final filteredTransactions = transactions
        .where(
            (transaction) => transaction['transactionType'] == transactionType)
        .toList();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryColor,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white54,
            ),
            child: ListTile(
              title: Text(
                transaction['recieverName'],
                style: AppFonts.Subtitle().copyWith(color: Colors.black),
              ),
              subtitle: Text(
                'Rs. ' + transaction['totalAmount'].toString(),
                style: AppFonts.Subtitle().copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
