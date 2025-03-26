import 'dart:io';
import 'package:flutter/material.dart';
import 'package:offline_blog_app/models/post.dart';
import 'package:offline_blog_app/providers/post_provider.dart';
import 'package:offline_blog_app/services/image_service.dart';
import 'package:offline_blog_app/widgets/image_picker_widget.dart';
import 'package:provider/provider.dart';
class CreateEditPostScreen extends StatefulWidget {
  final Post? post;

  const CreateEditPostScreen({Key? key, this.post}) : super(key: key);

  @override
  State<CreateEditPostScreen> createState() => _CreateEditPostScreenState();
}

class _CreateEditPostScreenState extends State<CreateEditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ImageService _imageService = ImageService();

  List<String> _selectedImagePaths = [];
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.post != null;

    if (_isEditing) {
      _titleController.text = widget.post!.title;
      _contentController.text = widget.post!.content;
      _selectedImagePaths = List.from(widget.post!.imagePaths);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    String? imagePath;
    if (source == ImageSource.camera) {
      imagePath = await _imageService.pickImageFromCamera();
    } else {
      imagePath = await _imageService.pickImageFromGallery();
    }

    if (imagePath != null) {
      setState(() {
        _selectedImagePaths.add(imagePath!);
      });
    }
  }

  Future<void> _pickMultipleImages() async {
    final List<String> imagePaths = await _imageService.pickMultipleImagesFromGallery();
    if (imagePaths.isNotEmpty) {
      setState(() {
        _selectedImagePaths.addAll(imagePaths);
      });
    }
  }

  void _removeImage(int index) {
    final imagePath = _selectedImagePaths[index];

    setState(() {
      _selectedImagePaths.removeAt(index);
    });

    // Only delete from storage if this is a new image (not already saved with post)
    if (_isEditing && !widget.post!.imagePaths.contains(imagePath)) {
      _imageService.deleteImage(imagePath);
    } else if (!_isEditing) {
      _imageService.deleteImage(imagePath);
    }
  }

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<PostProvider>(context, listen: false);
    bool success;

    if (_isEditing) {
      success = await provider.updatePost(
        widget.post!.id!,
        _titleController.text,
        _contentController.text,
        _selectedImagePaths,
      );
    } else {
      final newPost = await provider.createPost(
        _titleController.text,
        _contentController.text,
        _selectedImagePaths,
      );
      success = newPost != null;
    }

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Post updated successfully' : 'Post created successfully'),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Post' : 'Create Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _savePost,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter some content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ImagePickerWidget(
                imagePaths: _selectedImagePaths,
                onCameraPressed: () => _pickImage(ImageSource.camera),
                onGalleryPressed: () => _pickImage(ImageSource.gallery),
                onMultiplePressed: _pickMultipleImages,
                onDeletePressed: _removeImage,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePost,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _isEditing ? 'Update Post' : 'Create Post',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper enum for image source
enum ImageSource {
  camera,
  gallery,
}
