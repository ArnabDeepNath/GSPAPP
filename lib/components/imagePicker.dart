import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';

class CustomImagePicker extends StatefulWidget {
  final void Function(String imagePath)? onImageSelected;

  const CustomImagePicker({Key? key, this.onImageSelected}) : super(key: key);

  @override
  _CustomImagePickerState createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  final ImagePicker _picker = ImagePicker();
  String? selectedImagePath;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          selectedImagePath = pickedFile.path;
        });
        widget.onImageSelected?.call(selectedImagePath!);
      }
    } catch (e) {
      // Handle image picking error
      print('Image picking error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _pickImage,
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: selectedImagePath != null
                  ? Image.file(
                      File(selectedImagePath!),
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    )
                  : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_sharp,color: Colors.grey,),
                  Text('Click Here To Upload',style: TextStyle(color: Colors.grey),)
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
