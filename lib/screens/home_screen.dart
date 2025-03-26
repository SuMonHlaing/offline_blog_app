import 'package:flutter/material.dart';
import 'package:offline_blog_app/providers/post_provider.dart';
import 'package:offline_blog_app/screens/create_edit_post_screen.dart';
import 'package:offline_blog_app/screens/search_screen.dart';
import 'package:offline_blog_app/widgets/post_list.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSelectionMode = false;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _loadPosts() async {
    await Provider.of<PostProvider>(context, listen: false).loadPosts();
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

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
    });

    if (!_isSelectionMode) {
      Provider.of<PostProvider>(context, listen: false).clearSelection();
    }
  }

  Future<void> _deleteSelected() async {
    final provider = Provider.of<PostProvider>(context, listen: false);

    if (provider.selectedPostIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No posts selected')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Selected Posts'),
        content: Text('Are you sure you want to delete ${provider.selectedPostIds.length} posts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.deleteSelectedPosts();

              if (success) {
                setState(() {
                  _isSelectionMode = false;
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Posts deleted successfully')),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete posts')),
                  );
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
    final postProvider = Provider.of<PostProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Offline Blogger',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.search, size: 26),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isOnline ? Colors.green.shade700 : Colors.red.shade700,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isOnline ? Icons.cloud_done : Icons.cloud_off,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_isSelectionMode) ...[
            Text(
              '${postProvider.selectedPostIds.length} selected',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 26),
              tooltip: 'Delete Selected',
              onPressed: _deleteSelected,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: postProvider.isLoading
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: colorScheme.secondary),
            const SizedBox(height: 16),
            Text(
              'Loading your posts...',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          // Custom app header with post count
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Your Posts',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${postProvider.posts.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main post list
          Padding(
            padding: const EdgeInsets.only(top: 64),
            child: RefreshIndicator(
              onRefresh: _loadPosts,
              color: colorScheme.secondary,
              child: postProvider.posts.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.note_add,
                      size: 64,
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No posts yet',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to create your first post',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
                  : PostList(
                posts: postProvider.posts,
                selectionMode: _isSelectionMode,
              ),
            ),
          ),
        ],
      ),

      // Modern floating action buttons with gradient effect
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isSelectionMode)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: FloatingActionButton.extended(
                heroTag: 'cancel',
                onPressed: _toggleSelectionMode,
                backgroundColor: Colors.red.shade400,
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (postProvider.posts.isNotEmpty && !_isSelectionMode)
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    heroTag: 'selection',
                    onPressed: _toggleSelectionMode,
                    backgroundColor: colorScheme.primary,
                    child: const Icon(Icons.checklist_rounded),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.secondary,
                      const Color(0xFFFF9E80),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.secondary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  heroTag: 'add',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateEditPostScreen(),
                      ),
                    );
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  icon: const Icon(Icons.add),
                  label: const Text('New Post'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
