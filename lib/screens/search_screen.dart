import 'package:flutter/material.dart';
import '../widgets/markeela_fab.dart';
import '../services/catalog_service.dart';
import '../models/catalog_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final c = TextEditingController();
  String category = 'All';
  Future<List<CatalogItem>>? future;
  final service = CatalogService();

  @override
  void initState() {
    super.initState();
    future = service.list();
  }

  void run() =>
      setState(() => future = service.list(query: c.text, category: category));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Search')),
    floatingActionButton: const MarkeelaFab(mode: 'discovery'),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: c,
            onSubmitted: (_) => run(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search titles or creators',
              suffixIcon: IconButton(
                onPressed: run,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final x in ['All', 'Featured', 'Trending', 'New', 'Other'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(x),
                      selected: category == x,
                      onSelected: (_) {
                        category = x;
                        run();
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<CatalogItem>>(
              future: future,
              builder: (context, snapshot) {
                final items = snapshot.data ?? <CatalogItem>[];
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.play_arrow),
                      ),
                      title: Text(items[i].title),
                      subtitle: Text(items[i].creatorName),
                      trailing: Text('★ ${items[i].rating.toStringAsFixed(1)}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
