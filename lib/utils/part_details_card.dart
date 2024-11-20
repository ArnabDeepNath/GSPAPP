import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PartyDetailsCard extends StatelessWidget {
  final Party party;

  const PartyDetailsCard({super.key, required this.party});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            _buildRow('Name', party.name),
            Divider(
              thickness: 1,
              height: 1,
              color: Colors.grey.shade300,
            ),
            _buildRow('Contact', party.contactNumber),
            Divider(
              thickness: 1,
              height: 1,
              color: Colors.grey.shade300,
            ),
            _buildRow(
              'Balance',
              '₹ ${party.balance.toStringAsFixed(2)}',
              isBalance: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBalance = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label :',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: isBalance ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class Party {
  final String name;
  final String contactNumber;
  final double balance;

  Party({required this.name, required this.contactNumber, required this.balance});
}
