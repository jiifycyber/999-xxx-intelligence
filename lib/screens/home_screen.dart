import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import '../models/catalog_item.dart';
import 'search_screen.dart';
import 'creator_studio_screen.dart';
import 'library_screen.dart';
import 'admin_screen.dart';
import 'status_screen.dart';
import 'markeela_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service = CatalogService();
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _Discover(service: service),
      const SearchScreen(),
      const LibraryScreen(),
      const CreatorStudioScreen(),
      const AdminScreen(),
      const StatusScreen(),
      const MarkeelaScreen(),
    ];
    return Scaffold(
      body: Row(
        children: [
          if (MediaQuery.sizeOf(context).width > 850)
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: (v) => setState(() => index = v),
              extended: MediaQuery.sizeOf(context).width > 1150,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  '999XXX',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: Text('Discover'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  label: Text('Search'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.video_library_outlined),
                  label: Text('Library'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.upload_outlined),
                  label: Text('Creator Studio'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  label: Text('Admin'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.hub_outlined),
                  label: Text('System Status'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.auto_awesome),
                  label: Text('Markeela AI'),
                ),
              ],
            ),
          Expanded(child: pages[index]),
        ],
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width <= 850
          ? NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (v) => setState(() => index = v),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  label: 'Discover',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                NavigationDestination(
                  icon: Icon(Icons.video_library_outlined),
                  label: 'Library',
                ),
                NavigationDestination(
                  icon: Icon(Icons.upload_outlined),
                  label: 'Studio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  label: 'Admin',
                ),
                NavigationDestination(
                  icon: Icon(Icons.hub_outlined),
                  label: 'Status',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome),
                  label: 'Markeela',
                ),
              ],
            )
          : null,
    );
  }
}

class _Discover extends StatelessWidget {
  final CatalogService service;
  const _Discover({required this.service});

  @override
  Widget build(BuildContext context) => FutureBuilder<List<CatalogItem>>(
    future: service.list(),
    builder: (context, snap) {
      final items = snap.data ?? [];
      return CustomScrollView(
        slivers: [
          SliverAppBar.large(
            floating: true,
            title: const Text(
              '999XXX',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.account_circle_outlined),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43136C), Color(0xFF11264A)],
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DISCOVER',
                      style: TextStyle(
                        fontSize: 13,
                        letterSpacing: 3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Verified creator releases',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Modern discovery • personalized ranking • rights-gated publishing',
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, i) {
                final e = items[i];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _showDetail(context, e),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B1B29),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.play_circle_fill_rounded,
                                  size: 56,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            e.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            e.creatorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${e.views} views  •  ★ ${e.rating.toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }, childCount: items.length),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.sizeOf(context).width > 1200
                    ? 4
                    : MediaQuery.sizeOf(context).width > 800
                    ? 3
                    : MediaQuery.sizeOf(context).width > 500
                    ? 2
                    : 1,
                childAspectRatio: 1.25,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
            ),
          ),
        ],
      );
    },
  );

  void _showDetail(BuildContext context, CatalogItem e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .75,
        maxChildSize: .95,
        builder: (context, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              height: 260,
              decoration: BoxDecoration(
                color: const Color(0xFF151520),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_fill, size: 88),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              e.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            Text(e.creatorName, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(e.category)),
                Chip(label: Text('${e.views} views')),
                Chip(label: Text('★ ${e.rating.toStringAsFixed(1)}')),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border),
              label: const Text('Add to Favorites'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.report_outlined),
              label: const Text('Report / Rights Issue'),
            ),
          ],
        ),
      ),
    );
  }
}
