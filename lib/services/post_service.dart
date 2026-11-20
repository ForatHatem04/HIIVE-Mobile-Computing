import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../models/post_model.dart';

class PostService {
  // Tried in order. jsonplaceholder is blocked on some networks, so
  // dummyjson (same id/title/body/userId fields) is used as a fallback.
  static const List<String> apiUrls = [
    'https://jsonplaceholder.typicode.com/posts',
    'https://dummyjson.com/posts?limit=100',
  ];

  Future<List<Post>> getPosts() async {
    var box = await Hive.openBox<Post>('postsBox');

    for (final url in apiUrls) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          // jsonplaceholder returns a list; dummyjson wraps it in {"posts": [...]}
          final List<dynamic> data =
              decoded is List ? decoded : decoded['posts'] as List<dynamic>;
          List<Post> onlinePosts = data.map((e) => Post.fromJson(e)).toList();

          await box.clear();
          await box.addAll(onlinePosts);

          debugPrint('Loaded from $url and cached to Hive: ${onlinePosts.length}');
          return onlinePosts;
        }
        debugPrint('API $url returned ${response.statusCode}');
      } catch (e) {
        debugPrint('API $url failed, reason: $e');
      }
    }

    if (box.isNotEmpty) {
      debugPrint('Loaded from Hive offline: ${box.length}');
      return box.values.toList();
    } else {
      throw Exception('No Internet and No Cached Data');
    }
  }
}
