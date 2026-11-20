import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/post_model.dart';

class FavoritesService {
  static const String boxName = 'favoritesBox';

  Box<Post> get _box => Hive.box<Post>(boxName);

  ValueListenable<Box<Post>> listenable() => _box.listenable();

  bool isFavorite(int id) => _box.containsKey(id);

  List<Post> getFavorites() => _box.values.toList();

  Future<bool> toggleFavorite(Post post) async {
    if (isFavorite(post.id)) {
      await _box.delete(post.id);
      return false;
    }
    final copy = Post(
      id: post.id,
      title: post.title,
      body: post.body,
      userId: post.userId,
    );
    await _box.put(post.id, copy);
    return true;
  }
}
