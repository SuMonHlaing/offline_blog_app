import 'package:flutter/material.dart';
import 'package:offline_blog_app/models/post.dart';
import 'package:offline_blog_app/services/database_service.dart';
import 'package:offline_blog_app/services/image_service.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  List<Post> get posts => [..._posts];

  List<Post> _searchResults = [];
  List<Post> get searchResults => [..._searchResults];

  Set<int> _selectedPostIds = {};
  Set<int> get selectedPostIds => _selectedPostIds;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final DatabaseService _databaseService = DatabaseService.instance;
  final ImageService _imageService = ImageService();

  // Initialize - load posts from database
  Future<void> loadPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await _databaseService.readAllPosts();
    } catch (e) {
      debugPrint('Error loading posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create post
  Future<Post?> createPost(String title, String content, List<String> imagePaths) async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final newPost = Post(
        title: title,
        content: content,
        imagePaths: imagePaths,
        createdAt: now,
        updatedAt: now,
      );

      final createdPost = await _databaseService.createPost(newPost);
      _posts.insert(0, createdPost);

      return createdPost;
    } catch (e) {
      debugPrint('Error creating post: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update post
  Future<bool> updatePost(int id, String title, String content, List<String> imagePaths) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get existing post
      final existingPost = await _databaseService.readPost(id);
      if (existingPost == null) return false;

      // Identify images to delete
      final imagesToDelete = existingPost.imagePaths
          .where((path) => !imagePaths.contains(path))
          .toList();

      // Delete removed images
      for (var path in imagesToDelete) {
        await _imageService.deleteImage(path);
      }

      // Update the post
      final updatedPost = existingPost.copyWith(
        title: title,
        content: content,
        imagePaths: imagePaths,
        updatedAt: DateTime.now(),
      );

      final result = await _databaseService.updatePost(updatedPost);

      if (result > 0) {
        // Update in local list
        final index = _posts.indexWhere((post) => post.id == id);
        if (index != -1) {
          _posts[index] = updatedPost;
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating post: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete post
  Future<bool> deletePost(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get post to delete its images
      final post = await _databaseService.readPost(id);
      if (post != null) {
        // Delete all images
        await _imageService.deleteMultipleImages(post.imagePaths);

        // Delete from database
        final result = await _databaseService.deletePost(id);

        if (result > 0) {
          // Remove from local list
          _posts.removeWhere((post) => post.id == id);
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting post: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle post selection
  void togglePostSelection(int id) {
    if (_selectedPostIds.contains(id)) {
      _selectedPostIds.remove(id);
    } else {
      _selectedPostIds.add(id);
    }
    notifyListeners();
  }

  // Clear post selection
  void clearSelection() {
    _selectedPostIds.clear();
    notifyListeners();
  }

  // Delete selected posts
  Future<bool> deleteSelectedPosts() async {
    if (_selectedPostIds.isEmpty) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Get all selected posts
      final selectedPosts = _posts.where((post) => _selectedPostIds.contains(post.id)).toList();

      // Delete all images from selected posts
      for (var post in selectedPosts) {
        await _imageService.deleteMultipleImages(post.imagePaths);
      }

      // Delete posts from database
      final result = await _databaseService.deleteMultiplePosts(_selectedPostIds.toList());

      if (result > 0) {
        // Remove from local list
        _posts.removeWhere((post) => _selectedPostIds.contains(post.id));
        _selectedPostIds.clear();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting selected posts: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search posts
  Future<void> searchPosts(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _databaseService.searchPosts(query);
    } catch (e) {
      debugPrint('Error searching posts: $e');
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get post by id
  Future<Post?> getPostById(int id) async {
    try {
      return await _databaseService.readPost(id);
    } catch (e) {
      debugPrint('Error getting post by id: $e');
      return null;
    }
  }

// These methods were removed as part of the social platform integration removal
}
