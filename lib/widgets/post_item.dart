import 'dart:io';
import 'package:flutter/material.dart';
import 'package:offline_blog_app/models/post.dart';
import 'package:offline_blog_app/providers/post_provider.dart';
import 'package:offline_blog_app/screens/post_detail_screen.dart';
import 'package:offline_blog_app/utils/datetime_utils.dart';
import 'package:provider/provider.dart';

class PostItem extends StatelessWidget {
  final Post post;
  final bool selectionMode;

  const PostItem({
    Key? key,
    required this.post,
    required this.selectionMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PostProvider>(context);
    final isSelected = provider.selectedPostIds.contains(post.id);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: selectionMode && isSelected
            ? BorderSide(color: colorScheme.secondary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: selectionMode
            ? () => provider.togglePostSelection(post.id!)
            : () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postId: post.id!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.hasImages())
              Stack(
                children: [
                  // Image with gradient overlay
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Hero(
                      tag: 'post_image_${post.id}',
                      child: Image.file(
                        File(post.imagePaths.first),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Gradient overlay at the bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Date indicator on the image
                  Positioned(
                    bottom: 8,
                    left: 12,
                    child: Text(
                      formatDateTime(post.createdAt),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3.0,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Selection indicator if in selection mode
                  if (selectionMode && isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          post.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (selectionMode)
                        Checkbox(
                          activeColor: colorScheme.secondary,
                          value: isSelected,
                          onChanged: (_) => provider.togglePostSelection(post.id!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    post.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  if (!post.hasImages())
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDateTime(post.createdAt),
                          style: TextStyle(
                            color: colorScheme.outline,
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.text_snippet,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Text',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (post.hasImages())
                    Container(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.image,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post.imagePaths.length} ${post.imagePaths.length == 1 ? 'Image' : 'Images'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
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
