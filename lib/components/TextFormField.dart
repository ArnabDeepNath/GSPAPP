import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gspappfinal/constants/AppColor.dart';

// ignore: must_be_immutable
class TextFormFieldCustom extends StatefulWidget {
  String label;
  TextEditingController controller;
  Function(String)? onChange;
  String? Function(String?)? validator;
  bool obscureText;

  TextFormFieldCustom({
    super.key,
    required this.label,
    required this.controller,
    required this.onChange,
    required this.validator,
    required this.obscureText,
  });

  @override
  State<TextFormFieldCustom> createState() => _TextFormFieldCustomState();
}

class _TextFormFieldCustomState extends State<TextFormFieldCustom> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  style: GoogleFonts.inter(
                    color: Colors.black,
                  ),
                  validator: widget.validator,
                  controller: widget.controller,
                  obscureText: widget.obscureText,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: InputBorder.none,
                    labelText: "Enter ${widget.label}",
                    labelStyle: GoogleFonts.inter(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onChanged: widget.onChange, // Use the provided onChanged callback
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
