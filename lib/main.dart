import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const XxxIntelligenceApp());
}

class XxxIntelligenceApp extends StatelessWidget {
  const XxxIntelligenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '999 XXX Intelligence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF05091C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF24E7FF),
          secondary: Color(0xFFFFC928),
          surface: Color(0xFF0A1230),
        ),
      ),
      home: const AgeGate(),
    );
  }
}

class AgeGate extends StatefulWidget {
  const AgeGate({super.key});

  @override
  State<AgeGate> createState() => _AgeGateState();
}

class _AgeGateState extends State<AgeGate> {
  bool confirmed = false;

  @override
  Widget build(BuildContext context) {
    if (confirmed) {
      return const XxxShell();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF05091C), Color(0xFF071875), Color(0xFF09051E)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              margin: const EdgeInsets.all(24),
              color: const Color(0xFF0A1230),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      size: 58,
                      color: Color(0xFFFFC928),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      '999 XXX Intelligence',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Powered by 999 Intelligence Network',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'This platform is intended only for adults. '
                      'Continue only if you meet the legal age requirement '
                      'for adult content in your location.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => setState(() => confirmed = true),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('I am of legal age'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Access not granted.')),
                        );
                      },
                      child: const Text('Exit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum XxxSection {
  home,
  search,
  library,
  favorites,
  markeela,
  creators,
  account,
  settings,
}

class XxxShell extends StatefulWidget {
  const XxxShell({super.key});

  @override
  State<XxxShell> createState() => _XxxShellState();
}

class _XxxShellState extends State<XxxShell> {
  XxxSection section = XxxSection.home;
  bool gold = false;
  final searchController = TextEditingController();

  void go(XxxSection target) {
    setState(() => section = target);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 950;

    return Scaffold(
      drawer: desktop ? null : Drawer(child: _drawer()),
      body: SafeArea(
        child: Row(
          children: [
            if (desktop) SizedBox(width: 240, child: _drawer()),
            Expanded(
              child: Column(
                children: [
                  _topHeader(context, desktop),
                  _featureStrip(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _screen(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: width < 700
          ? NavigationBar(
              backgroundColor: const Color(0xFF071045),
              selectedIndex: switch (section) {
                XxxSection.home => 0,
                XxxSection.search => 1,
                XxxSection.markeela => 2,
                XxxSection.favorites => 3,
                _ => 4,
              },
              onDestinationSelected: (index) {
                go(switch (index) {
                  0 => XxxSection.home,
                  1 => XxxSection.search,
                  2 => XxxSection.markeela,
                  3 => XxxSection.favorites,
                  _ => XxxSection.account,
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search_rounded),
                  label: 'Search',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_rounded),
                  label: 'Markeela',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_rounded),
                  label: 'Favorites',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_rounded),
                  label: 'Account',
                ),
              ],
            )
          : null,
    );
  }

  Widget _drawer() {
    final items = <(XxxSection, String, IconData)>[
      (XxxSection.home, 'Discover', Icons.explore_rounded),
      (XxxSection.search, 'Search', Icons.search_rounded),
      (XxxSection.library, 'Library', Icons.video_library_rounded),
      (XxxSection.favorites, 'Favorites', Icons.favorite_rounded),
      (XxxSection.markeela, 'Agent Duke Da Boss X', Icons.auto_awesome_rounded),
      (XxxSection.creators, 'Creator Studio', Icons.upload_rounded),
      (XxxSection.account, 'Account', Icons.person_rounded),
      (XxxSection.settings, 'Settings', Icons.settings_rounded),
    ];

    return Container(
      color: const Color(0xFF070D2A),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 22, 18, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFF24E7FF),
                    child: Icon(Icons.diamond_rounded, color: Colors.black),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '999 XXX',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'INTELLIGENCE',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 2,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  for (final item in items)
                    ListTile(
                      selected: section == item.$1,
                      leading: Icon(item.$3),
                      title: Text(item.$2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        go(item.$1);
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Powered by\n999 Intelligence Network',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topHeader(BuildContext context, bool desktop) {
    return Container(
      color: const Color(0xFF071045),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          if (!desktop)
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded, size: 30),
              ),
            ),
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '999 XXX INTELLIGENCE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
                Text(
                  'Creator intelligence • discovery • AI',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Search',
            onPressed: () => go(XxxSection.search),
            icon: const Icon(Icons.search_rounded, size: 29),
          ),
        ],
      ),
    );
  }

  Widget _featureStrip() {
    return Container(
      color: const Color(0xFF090F3A),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            InkWell(
              onTap: () {
                setState(() => gold = !gold);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      gold ? 'Gold mode enabled.' : 'Gold mode disabled.',
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFDC58), Color(0xFFC78900)],
                  ),
                ),
                child: Text(
                  gold ? 'GOLD ✓' : 'GOLD',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            _stripButton(
              Icons.explore_rounded,
              'Discover',
              () => go(XxxSection.home),
            ),
            _stripButton(
              Icons.sports_esports_rounded,
              'Interactive',
              () => _message(
                'Interactive',
                'Interactive experiences hub opened.',
              ),
            ),
            _stripButton(
              Icons.favorite_border_rounded,
              'Favorites',
              () => go(XxxSection.favorites),
            ),
            _stripButton(
              Icons.auto_awesome_rounded,
              'AI',
              () => go(XxxSection.markeela),
            ),
            _stripButton(
              Icons.person_outline_rounded,
              'Account',
              () => go(XxxSection.account),
            ),
            _stripButton(
              Icons.settings_rounded,
              'Settings',
              () => go(XxxSection.settings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stripButton(IconData icon, String label, VoidCallback action) {
    return InkWell(
      onTap: action,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        child: Column(
          children: [
            Icon(icon, size: 25),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _screen() {
    return switch (section) {
      XxxSection.home => _discover(),
      XxxSection.search => _search(),
      XxxSection.library => _library(),
      XxxSection.favorites => _favorites(),
      XxxSection.markeela => _markeela(),
      XxxSection.creators => _creators(),
      XxxSection.account => _account(),
      XxxSection.settings => _settings(),
    };
  }

  Widget _discover() {
    return ListView(
      key: const ValueKey('discover'),
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'FEATURED RELEASES',
          style: TextStyle(
            color: Color(0xFFFFD83D),
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFF7000FF), Color(0xFF074DFF)],
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DISCOVER',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Verified creator releases',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 6),
              Text(
                'Personalized discovery • creator tools • rights-aware publishing',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _responsiveCards(),
        const SizedBox(height: 26),
        const Text(
          'TRENDING NOW',
          style: TextStyle(
            color: Color(0xFFFFD83D),
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        _largeReleaseCard('Trending Creator Spotlight', '18.2K views • ★ 4.9'),
        _largeReleaseCard('Today’s Featured Release', '12.8K views • ★ 4.8'),
        _largeReleaseCard('New Creator Upload', '7.4K views • ★ 4.7'),
      ],
    );
  }

  Widget _responsiveCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 1050
            ? 3
            : constraints.maxWidth > 620
            ? 2
            : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            _smallCard(
              'Featured Creator Release',
              'Verified Creator',
              '12,840 views • ★ 4.8',
            ),
            _smallCard('Trending Release', 'Studio 999', '9,431 views • ★ 4.6'),
            _smallCard(
              'New Creator Upload',
              'New Creator',
              '2,381 views • ★ 4.5',
            ),
          ],
        );
      },
    );
  }

  Widget _smallCard(String title, String creator, String details) {
    return Card(
      color: const Color(0xFF101A42),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _message(title, 'Opening release details for $creator.'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF252E62),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              Text(creator, style: const TextStyle(color: Colors.white70)),
              Text(
                details,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _largeReleaseCard(String title, String details) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: const Color(0xFF0D1740),
      child: InkWell(
        onTap: () => _message(title, 'Release details opened.'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF111A44), Color(0xFF222E75)],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  size: 72,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          details,
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _message('Favorite added', title),
                    icon: const Icon(Icons.favorite_border_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _search() {
    return ListView(
      key: const ValueKey('search'),
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Search 999 XXX Intelligence',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: searchController,
          onSubmitted: (value) {
            _message(
              'Search',
              value.isEmpty
                  ? 'Enter a search term.'
                  : 'Searching for “$value”.',
            );
          },
          decoration: InputDecoration(
            hintText: 'Search creators, releases, categories…',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              onPressed: () {
                _message(
                  'Search',
                  searchController.text.isEmpty
                      ? 'Enter a search term.'
                      : 'Searching for “${searchController.text}”.',
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
            filled: true,
            fillColor: const Color(0xFF101A42),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _library() {
    return _simplePage(
      'Library',
      Icons.video_library_rounded,
      'Saved and purchased releases will appear here.',
    );
  }

  Widget _favorites() {
    return _simplePage(
      'Favorites',
      Icons.favorite_rounded,
      'Your favorite creators and releases will appear here.',
    );
  }

  Widget _markeela() {
    return ListView(
      key: const ValueKey('markeela'),
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Agent Duke Da Boss X',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'AI Intelligence Operator',
          style: TextStyle(color: Color(0xFF24E7FF)),
        ),
        const SizedBox(height: 18),
        Card(
          color: const Color(0xFF101A42),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 52,
                  color: Color(0xFF24E7FF),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Ask Agent Duke Da Boss X about creators, discovery, publishing, '
                  'account tools, recommendations, or platform operations.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Ask Agent Duke Da Boss X…',
                    suffixIcon: IconButton(
                      onPressed: () => _message(
                        'Agent Duke Da Boss X',
                        'AI interface connected. Live model/backend can be attached to this control.',
                      ),
                      icon: const Icon(Icons.arrow_upward_rounded),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _creators() {
    return _simplePage(
      'Creator Studio',
      Icons.upload_rounded,
      'Upload, manage, schedule, and review creator releases.',
      button: 'Create Release',
    );
  }

  Widget _account() {
    return _simplePage(
      'Account',
      Icons.person_rounded,
      'Manage your profile, membership, privacy, and account preferences.',
      button: 'Manage Account',
    );
  }

  Widget _settings() {
    return ListView(
      key: const ValueKey('settings'),
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: gold,
          onChanged: (value) => setState(() => gold = value),
          title: const Text('Gold experience'),
          subtitle: const Text('Premium visual and content mode'),
        ),
        ListTile(
          leading: const Icon(Icons.security_rounded),
          title: const Text('Privacy & Security'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () =>
              _message('Privacy & Security', 'Security settings opened.'),
        ),
        ListTile(
          leading: const Icon(Icons.verified_user_rounded),
          title: const Text('Age & Content Controls'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _message(
            'Age & Content Controls',
            'Age and content controls opened.',
          ),
        ),
      ],
    );
  }

  Widget _simplePage(
    String title,
    IconData icon,
    String body, {
    String? button,
  }) {
    return Center(
      key: ValueKey(title),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            color: const Color(0xFF101A42),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 58, color: const Color(0xFF24E7FF)),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(body, textAlign: TextAlign.center),
                  if (button != null) ...[
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: () => _message(title, '$button opened.'),
                      child: Text(button),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _message(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
