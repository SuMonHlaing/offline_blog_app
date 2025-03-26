import 'dart:io';
import 'package:flutter/material.dart';

class ImagePickerWidget extends StatelessWidget {
  final List<String> imagePaths;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onMultiplePressed;
  final Function(int) onDeletePressed;

  const ImagePickerWidget({
    Key? key,
    required this.imagePaths,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onMultiplePressed,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: onCameraPressed,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onGalleryPressed,
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onMultiplePressed,
              icon: const Icon(Icons.photo_library),
              label: const Text('Multiple'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        imagePaths.isEmpty
            ? Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: Text(
              'No images selected',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        )
            : SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(imagePaths[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 13,
                    child: GestureDetector(
                      onTap: () => onDeletePressed(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
