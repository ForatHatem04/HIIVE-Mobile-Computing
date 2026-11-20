import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/post_model.dart';
import '../services/favorites_service.dart';
import '../services/post_service.dart';
import '../widgets/post_card.dart';
import 'favorites_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final PostService _postService = PostService();
  final FavoritesService _favoritesService = FavoritesService();
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _loadPosts();
  }

  // Marks the error as handled so it never surfaces as an "Unhandled
  // Exception"; the FutureBuilder still receives it and shows the error UI.
  Future<List<Post>> _loadPosts() {
    final future = _postService.getPosts();
    future.ignore();
    return future;
  }

  Future<void> _refresh() async {
    setState(() => _postsFuture = _loadPosts());
    try {
      await _postsFuture;
    } catch (_) {
      // Error is already shown by the FutureBuilder; don't let it escape
      // as an unhandled exception from the Retry button / pull-to-refresh.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            tooltip: 'Favorites',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
                ],
              ),
            );
          }
          final posts = snapshot.data ?? [];

          return ValueListenableBuilder<Box<Post>>(
            valueListenable: _favoritesService.listenable(),
            builder: (context, _, __) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostCard(
                      post: post,
                      isFavorite: _favoritesService.isFavorite(post.id),
                      onToggleFavorite: () =>
                          _favoritesService.toggleFavorite(post),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
