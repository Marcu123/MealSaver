import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:meal_saver_phone/services/api_service.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(File?) onImageSelected;
  final String? username;
  final String? existingImageUrl;

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.username,
    this.existingImageUrl,
  });

  @override
  ImagePickerWidgetState createState() => ImagePickerWidgetState();
}

class ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _selectedImage;
  String? _uploadedImageUrl;
  final ImagePicker _picker = ImagePicker();
  final CropController _cropController = CropController();
  final ApiService _apiService = ApiService();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedImage = await _cropImage(context, File(pickedFile.path));

      if (croppedImage != null) {
        setState(() {
          _selectedImage = croppedImage;
        });

        final bytes = croppedImage.readAsBytesSync();

        final imageUrl = await _apiService.uploadToCloudinary(bytes);
        if (imageUrl != null && widget.username != null) {
          await _apiService.sendImageUrlToBackend(widget.username!, imageUrl);
          setState(() {
            _uploadedImageUrl = imageUrl;
          });
        }

        widget.onImageSelected(croppedImage);
      }
    }
  }

  Future<File?> _cropImage(BuildContext context, File imageFile) async {
    return await Navigator.push<File?>(
      context,
      MaterialPageRoute(
        builder:
            (_) => _ImageCropperScreen(
              imageFile: imageFile,
              controller: _cropController,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget =
        _selectedImage != null
            ? Image.file(
              _selectedImage!,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            )
            : widget.existingImageUrl != null
            ? Image.network(
              widget.existingImageUrl!,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            )
            : Image.asset('assets/images/logo.png', width: 150, height: 150);

    return Column(
      children: [
        GestureDetector(onTap: _pickImage, child: ClipOval(child: imageWidget)),
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

  String? get uploadedImageUrl => _uploadedImageUrl;
}

class _ImageCropperScreen extends StatelessWidget {
  final File imageFile;
  final CropController controller;

  const _ImageCropperScreen({
    required this.imageFile,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Crop(
                image: imageFile.readAsBytesSync(),
                controller: controller,
                withCircleUi: true,
                aspectRatio: 1,
                onCropped: (Uint8List data) async {
                  final croppedFile = File(
                    '${imageFile.parent.path}/cropped_${imageFile.path.split('/').last}',
                  );
                  await croppedFile.writeAsBytes(data);
                  Navigator.pop(context, croppedFile);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => controller.crop(),
                    child: const Text('Crop'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
