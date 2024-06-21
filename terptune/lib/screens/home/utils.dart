import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
   final XFile? _imageFile = await _imagePicker.pickImage(source: source);

    if (_imageFile != null) {
        return await _imageFile.readAsBytes();
    }
}