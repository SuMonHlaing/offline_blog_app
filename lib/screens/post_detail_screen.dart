import 'dart:io';
import 'package:flutter/material.dart';
import 'package:offline_blog_app/models/post.dart';
import 'package:offline_blog_app/providers/post_provider.dart';
import 'package:offline_blog_app/screens/create_edit_post_screen.dart';
import 'package:offline_blog_app/services/share_service.dart';
import 'package:offline_blog_app/utils/datetime_utils.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Post? _post;
  bool _isLoading = true;
  bool _isOnline = false;
  final ShareService _shareService = ShareService();

  @override
  void initState() {
    super.initState();
    _loadPost();
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _loadPost() async {
    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<PostProvider>(context, listen: false);
    final post = await provider.getPostById(widget.postId);

    if (mounted) {
      setState(() {
        _post = post;
        _isLoading = false;
      });
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  void _sharePost() {
    if (_post != null) {
      _shareService.sharePost(_post!, context);
    }
  }

  void _editPost() {
    if (_post != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateEditPostScreen(post: _post),
        ),
      ).then((_) => _loadPost());
    }
  }

  void _deletePost() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (_post != null) {
                final provider = Provider.of<PostProvider>(context, listen: false);
                final success = await provider.deletePost(_post!.id!);

                if (success) {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to delete post')),
                    );
                  }
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isLoading ? null : _sharePost,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _isLoading ? null : _editPost,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : _deletePost,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _post == null
          ? const Center(child: Text('Post not found'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _post!.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              formatDateTime(_post!.updatedAt),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            if (_post!.hasImages()) ...[
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _post!.imagePaths.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_post!.imagePaths[index]),
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              _post!.content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),

    );
  }
}
