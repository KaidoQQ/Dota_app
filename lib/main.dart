import 'dart:convert';
import 'package:flutter/foundation.dart'; // For compute
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'hero_model.dart';
import 'item_model.dart';

void main() {
  runApp(const HeroExplorerApp());
}

class HeroExplorerApp extends StatelessWidget {
  const HeroExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dota 2 Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.redAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HeroListScreen(),
    const ItemListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.redAccent,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Heroes'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Items'),
        ],
      ),
    );
  }
}

// --- HEROES SECTION ---

class HeroListScreen extends StatefulWidget {
  const HeroListScreen({super.key});

  @override
  State<HeroListScreen> createState() => _HeroListScreenState();
}

class _HeroListScreenState extends State<HeroListScreen> {
  List<DotaHero> _allHeroes = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadHeroes();
  }

  Future<void> _loadHeroes() async {
    try {
      final response = await http.get(Uri.parse('https://api.opendota.com/api/heroStats'));
      if (response.statusCode == 200) {
        // Compute
        final heroes = await compute(_parseHeroes, response.body);
        setState(() {
          _allHeroes = heroes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  static List<DotaHero> _parseHeroes(String responseBody) {
    final List jsonResponse = json.decode(responseBody);
    return jsonResponse.map((hero) => DotaHero.fromJson(hero)).toList()
      ..sort((a, b) => a.localizedName.compareTo(b.localizedName));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dota 2 Heroes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: HeroSearchDelegate(_allHeroes)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : RefreshIndicator(
                  onRefresh: _loadHeroes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _allHeroes.length,
                    itemBuilder: (context, index) => HeroCard(hero: _allHeroes[index]),
                  ),
                ),
    );
  }
}

class HeroCard extends StatelessWidget {
  final DotaHero hero;
  const HeroCard({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => HeroDetailSheet(hero: hero),
        ),
        child: Row(
          children: [
            Image.network(
              hero.imageUrl,
              width: 120,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 80,
                color: Colors.grey[800],
                child: const Icon(Icons.broken_image),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hero.localizedName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${hero.attributeLabel} • ${hero.attackType}', style: TextStyle(color: Colors.grey[400])),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeroDetailSheet extends StatelessWidget {
  final DotaHero hero;
  const HeroDetailSheet({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: controller,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(hero.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 100)),
            ),
            const SizedBox(height: 20),
            Text(hero.localizedName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(hero.roles.join(', '), textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent[100])),
            const Divider(height: 40),
            _statRow(Icons.favorite, 'Health', '${hero.maxHealth}', Colors.green),
            _statRow(Icons.flash_on, 'Mana', '${hero.maxMana}', Colors.blue),
            _statRow(Icons.shield, 'Armor', hero.totalArmor.toStringAsFixed(1), Colors.grey),
            _statRow(Icons.bolt, 'Stamina', '${hero.stamina}', Colors.yellow),
            _statRow(Icons.directions_run, 'Speed', '${hero.moveSpeed}', Colors.orange),
            _statRow(Icons.fitness_center, 'Strength', '${hero.baseStr}', Colors.red),
            _statRow(Icons.auto_fix_high, 'Intelligence', '${hero.baseInt}', Colors.cyan),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class HeroSearchDelegate extends SearchDelegate {
  final List<DotaHero> heroes;
  HeroSearchDelegate(this.heroes);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white60),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final results = heroes
        .where((h) => h.localizedName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    
    if (results.isEmpty) {
      return const Center(child: Text('No heroes found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: results.length,
      itemBuilder: (context, index) => HeroCard(hero: results[index]),
    );
  }
}

// --- ITEMS SECTION ---

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  List<DotaItem> _allItems = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final response = await http.get(Uri.parse('https://api.opendota.com/api/constants/items'));
      if (response.statusCode == 200) {
        // COMPUTE
        final items = await compute(_parseItems, response.body);
        setState(() {
          _allItems = items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  static List<DotaItem> _parseItems(String responseBody) {
    final Map<String, dynamic> jsonResponse = json.decode(responseBody);
    return jsonResponse.entries
        .map((e) => DotaItem.fromJson(e.key, e.value))
        .where((item) => item.localizedName != null && item.cost != null && item.cost! > 0)
        .toList()
      ..sort((a, b) => (a.cost ?? 0).compareTo(b.cost ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dota 2 Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: ItemSearchDelegate(_allItems)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _allItems.length,
                  itemBuilder: (context, index) => ItemCard(item: _allItems[index]),
                ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final DotaItem item;
  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ItemDetailSheet(item: item),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag, size: 40),
                      )
                    : const Icon(Icons.shopping_bag, size: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.localizedName ?? 'Item',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${item.cost} 🪙',
                style: const TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemDetailSheet extends StatelessWidget {
  final DotaItem item;
  const ItemDetailSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: controller,
          children: [
            if (item.imageUrl.isNotEmpty) 
              Center(child: Image.network(item.imageUrl, height: 100, errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag, size: 80))),
            const SizedBox(height: 10),
            Text(item.localizedName ?? 'Item', textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Cost: ${item.cost} Gold', textAlign: TextAlign.center, style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            if (item.fullDescription.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  item.fullDescription,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
              onPressed: () => Navigator.pop(context), 
              child: const Text('Close')
            ),
          ],
        ),
      ),
    );
  }
}

class ItemSearchDelegate extends SearchDelegate {
  final List<DotaItem> items;
  ItemSearchDelegate(this.items);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white60),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final results = items
        .where((i) => (i.localizedName ?? '').toLowerCase().contains(query.toLowerCase()))
        .toList();
    
    if (results.isEmpty) {
      return const Center(child: Text('No items found'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) => ItemCard(item: results[index]),
    );
  }
}
