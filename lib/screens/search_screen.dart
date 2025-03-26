import 'package:flutter/material.dart';
import 'package:offline_blog_app/providers/post_provider.dart';
import 'package:offline_blog_app/widgets/post_list.dart';
import 'package:provider/provider.dart';
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _currentQuery = _searchController.text;
    });

    if (_searchController.text.trim().isNotEmpty) {
      _performSearch();
    }
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    await Provider.of<PostProvider>(context, listen: false)
        .searchPosts(_searchController.text);

    if (mounted) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    Provider.of<PostProvider>(context, listen: false).searchPosts('');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PostProvider>(context);
    final searchResults = provider.searchResults;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search posts...',
            border: InputBorder.none,
            hintStyle: const TextStyle(color: Colors.black),
            suffixIcon: _currentQuery.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.black),
              onPressed: _clearSearch,
            )
                : null,
          ),
          style: const TextStyle(color: Colors.black),
          cursorColor: Colors.black,
          autofocus: true,
          onSubmitted: (_) => _performSearch(),
        ),
      ),
      body: Column(
        children: [
          if (_isSearching)
            const LinearProgressIndicator(),
          Expanded(
            child: _currentQuery.isEmpty
                ? const Center(
              child: Text('Type something to search'),
            )
                : searchResults.isEmpty
                ? const Center(
              child: Text('No results found'),
            )
                : PostList(
              posts: searchResults,
              selectionMode: false,
            ),
          ),
        ],
      ),
    );
  }
}
