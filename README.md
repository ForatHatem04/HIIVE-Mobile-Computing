# posts_app

A Flutter app that fetches posts from an API, caches them with Hive for offline use, and lets you mark posts as favorites.

## Features

- Loads posts from the API (jsonplaceholder, falling back to dummyjson)
- Caches posts in Hive so they are still available offline
- Star a post to add it to a separate favorites box
- Favorites screen listing all starred posts
- Pull to refresh and a Retry button when loading fails

## Screenshots

### Posts list

![Posts list](Screenshots/Pasted%20image.png)

### Marking favorites

![Posts with favorites starred](Screenshots/Pasted%20image%20(2).png)

### Favorites screen

![Favorites screen](Screenshots/Pasted%20image%20(3).png)

## Running

```bash
flutter pub get
dart run build_runner build   # generates post_model.g.dart if missing
flutter run
```
