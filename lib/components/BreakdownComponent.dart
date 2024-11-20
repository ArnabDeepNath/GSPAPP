import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BreakDownComponent extends StatefulWidget {
  final int qty;
  final String unit;
  final String salePrice;
  final String taxRate;

  const BreakDownComponent({
    Key? key,
    required this.qty,
    required this.unit,
    required this.salePrice,
    required this.taxRate,
  }) : super(key: key);

  @override
  State<BreakDownComponent> createState() => _BreakDownComponentState();
}

class _BreakDownComponentState extends State<BreakDownComponent> {
  String _calcTotal(String cpu, int qty) {
    double total = qty * double.parse(cpu);
    return total.toStringAsFixed(2);
  }

  String _calcTotalTax(String cpu, int qty, String taxRate) {
    double _taxRate = extractPercentage(taxRate);
    double totalTax = ((qty * double.parse(cpu)) * _taxRate) / 100;
    print('$qty $taxRate $cpu');
    print(totalTax);
    return totalTax.toStringAsFixed(2);
  }

  double extractPercentage(String input) {
    List<String> parts = input.split('%');
    if (parts.length == 2) {
      String percentageStr = parts[0].replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(percentageStr) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: Offset(0, 2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Item:",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Expanded(
                  child: Text(
                    "Box",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rate:",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  widget.salePrice,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "IGST@${widget.taxRate}:",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  _calcTotalTax(widget.salePrice, widget.qty, widget.taxRate),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Amount:",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  _calcTotal(widget.salePrice, widget.qty),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Qty:",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  widget.qty.toString(),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Amount:",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  _calcTotal(widget.salePrice, widget.qty),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
