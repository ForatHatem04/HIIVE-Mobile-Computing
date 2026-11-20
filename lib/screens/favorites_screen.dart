import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/post_model.dart';
import '../services/favorites_service.dart';
import '../widgets/post_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesService = FavoritesService();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: ValueListenableBuilder<Box<Post>>(
        valueListenable: favoritesService.listenable(),
        builder: (context, box, _) {
          final favorites = favoritesService.getFavorites();

          if (favorites.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_border, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No favorites yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap the star on any post to save it here.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final post = favorites[index];
              return PostCard(
                post: post,
                isFavorite: true,
                onToggleFavorite: () => favoritesService.toggleFavorite(post),
              );
            },
          );
        },
      ),
    );
  }
}
