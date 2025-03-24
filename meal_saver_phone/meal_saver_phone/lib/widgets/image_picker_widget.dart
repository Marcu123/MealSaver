import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(File?) onImageSelected;

  const ImagePickerWidget({super.key, required this.onImageSelected});

  @override
  ImagePickerWidgetState createState() => ImagePickerWidgetState();
}

class ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File? croppedImage = await _cropImage(File(pickedFile.path));

      if (croppedImage != null) {
        setState(() {
          _selectedImage = croppedImage;
        });
        widget.onImageSelected(_selectedImage);
      }
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          cropStyle: CropStyle.circle,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Colors.deepPurple,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          doneButtonTitle: 'Save',
          cancelButtonTitle: 'Cancel',
        ),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child:
              _selectedImage == null
                  ? Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                    height: 150,
                  )
                  : ClipOval(
                    child: Image.file(
                      _selectedImage!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _pickImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 130, 24, 230),
            foregroundColor: Colors.white,
          ),
          child: const Text('Upload Image'),
        ),
      ],
    );
  }
}
