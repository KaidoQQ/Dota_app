class DotaItem {
  final int id;
  final String name; 
  final String? localizedName;
  final int? cost;
  final String? description;
  final String? notes;
  final String? lore;
  final List<dynamic>? abilities;
  final List<dynamic>? attrib;
  final String? img;

  DotaItem({
    required this.id,
    required this.name,
    this.localizedName,
    this.cost,
    this.description,
    this.notes,
    this.lore,
    this.abilities,
    this.attrib,
    this.img,
  });

  factory DotaItem.fromJson(String key, Map<String, dynamic> json) {
    return DotaItem(
      id: json['id'] ?? 0,
      name: key,
      localizedName: json['dname'] ?? json['localized_name'],
      cost: json['cost'] is int ? json['cost'] : int.tryParse(json['cost']?.toString() ?? '0'),
      description: json['desc'] ?? json['hint']?.toString(),
      notes: json['notes'],
      lore: json['lore'],
      abilities: json['abilities'],
      attrib: json['attrib'],
      img: json['img'],
    );
  }

  String get fullDescription {
    List<String> parts = [];

    // 1. Attributes (Stats)
    if (attrib != null) {
      for (var attr in attrib!) {
        if (attr['display'] != null) {
          String display = attr['display'].toString();
          String value = attr['value'] is List ? attr['value'].join('/') : attr['value'].toString();
          parts.add(display.replaceAll('{value}', value));
        }
      }
    }

    // 2. Main Description
    if (description != null && description!.isNotEmpty) {
      parts.add(description!);
    }

    // 3. Abilities
    if (abilities != null) {
      for (var ability in abilities!) {
        String title = ability['title'] ?? '';
        String desc = ability['description'] ?? '';
        if (title.isNotEmpty || desc.isNotEmpty) {
          parts.add('${title.toUpperCase()}: $desc');
        }
      }
    }

    // 4. Notes
    if (notes != null && notes!.isNotEmpty) {
      parts.add('Note: $notes');
    }

    // 5. Lore
    if (lore != null && lore!.isNotEmpty) {
      parts.add('Lore: $lore');
    }

    return parts.join('\n\n').replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  String get imageUrl {
    if (name.isEmpty) return '';

    String itemNameShort = name.replaceAll('item_', '');

    return 'https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota_react/items/$itemNameShort.png';
  }
}
