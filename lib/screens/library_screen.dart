import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My Library')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _tile(Icons.favorite, 'Favorites', 'Saved catalog items'),
        _tile(Icons.history, 'Watch History', 'Recently viewed items'),
        _tile(
          Icons.playlist_play,
          'Playlists',
          'Create and organize playlists',
        ),
        _tile(
          Icons.shopping_bag_outlined,
          'Purchases',
          'Owned purchases and entitlements',
        ),
        _tile(
          Icons.workspace_premium_outlined,
          'Subscriptions',
          'Creator and platform memberships',
        ),
      ],
    ),
  );
  Widget _tile(IconData i, String t, String s) => Card(
    child: ListTile(
      leading: Icon(i),
      title: Text(t),
      subtitle: Text(s),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}
