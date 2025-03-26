import 'dart:io';
import 'package:flutter/material.dart';
import 'package:offline_blog_app/models/post.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  // Share a post (text and images)
  Future<void> sharePost(Post post, BuildContext context) async {
    try {
      String content = '${post.title}\n\n${post.content}';

      if (post.hasImages()) {
        // If the post has images, share both text and images
        await Share.shareXFiles(
          post.imagePaths.map((path) => XFile(path)).toList(),
          text: content,
          subject: post.title,
        );
      } else {
        // If post has only text, share just the text
        await Share.share(
          content,
          subject: post.title,
        );
      }
    } catch (e) {
      debugPrint('Error sharing post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sharing post')),
      );
    }
  }

  // Create a temporary shareable file for text content
  Future<File> _createShareableTextFile(Post post) async {
    final Directory tempDir = await getTemporaryDirectory();
    final File file = File('${tempDir.path}/shared_post.txt');

    // Write post content to file
    String content = '${post.title}\n\n${post.content}';
    return file.writeAsString(content);
  }
}
