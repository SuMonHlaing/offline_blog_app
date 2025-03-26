import 'package:flutter/material.dart';
import 'package:offline_blog_app/models/post.dart';
import 'package:offline_blog_app/widgets/post_item.dart';

class PostList extends StatelessWidget {
  final List<Post> posts;
  final bool selectionMode;

  const PostList({
    Key? key,
    required this.posts,
    required this.selectionMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No posts yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a new post to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostItem(
          post: posts[index],
          selectionMode: selectionMode,
        );
      },
    );
  }
}
