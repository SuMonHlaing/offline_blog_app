import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:math';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();

  // Pick image from camera
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        return await _saveImageToLocalStorage(File(image.path));
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  // Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        return await _saveImageToLocalStorage(File(image.path));
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  // Pick multiple images from gallery
  Future<List<String>> pickMultipleImagesFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      List<String> savedImagePaths = [];
      for (var image in images) {
        final path = await _saveImageToLocalStorage(File(image.path));
        if (path != null) {
          savedImagePaths.add(path);
        }
      }
      return savedImagePaths;
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  // Save image to local storage
  Future<String?> _saveImageToLocalStorage(File image) async {
    try {
      final Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final String path = join(documentsDirectory.path, 'social_blogger_images');

      // Create the directory if it doesn't exist
      await Directory(path).create(recursive: true);

      // Generate a unique filename to avoid overwriting
      final String uniqueFileName = 'img_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}.jpg';
      final String imagePath = join(path, uniqueFileName);

      // Copy the image to application documents directory
      await image.copy(imagePath);

      return imagePath;
    } catch (e) {
      debugPrint('Error saving image to local storage: $e');
      return null;
    }
  }

  // Delete image from local storage
  Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  // Delete multiple images
  Future<void> deleteMultipleImages(List<String> imagePaths) async {
    for (String path in imagePaths) {
      await deleteImage(path);
    }
  }
}
