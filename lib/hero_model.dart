class DotaHero {
  final int id;
  final String name; 
  final String localizedName;
  final String primaryAttr;
  final String attackType;
  final List<String> roles;
  final int baseHealth;
  final int baseMana;
  final int moveSpeed;
  final int baseStr;
  final int baseInt;
  final int baseAgi;
  final double baseArmor;

  DotaHero({
    required this.id,
    required this.name,
    required this.localizedName,
    required this.primaryAttr,
    required this.attackType,
    required this.roles,
    required this.baseHealth,
    required this.baseMana,
    required this.moveSpeed,
    required this.baseStr,
    required this.baseInt,
    required this.baseAgi,
    required this.baseArmor,
  });

  factory DotaHero.fromJson(Map<String, dynamic> json) {
    return DotaHero(
      id: json['id'],
      name: json['name'] ?? '',
      localizedName: json['localized_name'] ?? 'Unknown',
      primaryAttr: json['primary_attr'] ?? '',
      attackType: json['attack_type'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      baseHealth: json['base_health'] ?? 200,
      baseMana: json['base_mana'] ?? 75,
      moveSpeed: json['move_speed'] ?? 300,
      baseStr: json['base_str'] ?? 0,
      baseInt: json['base_int'] ?? 0,
      baseAgi: json['base_agi'] ?? 0,
      baseArmor: (json['base_armor'] ?? 0).toDouble(),
    );
  }

  int get maxHealth => baseHealth + (baseStr * 22);
  int get maxMana => baseMana + (baseInt * 12);
  double get totalArmor => baseArmor + (baseAgi / 6);
  int get stamina => (maxHealth + (totalArmor * 50)).toInt();

  String get imageUrl {
    if (name.isEmpty) return '';
    final heroNameShort = name.replaceAll('npc_dota_hero_', '');
    return 'https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota_react/heroes/$heroNameShort.png';
  }

  String get attributeLabel {
    switch (primaryAttr) {
      case 'str': return 'Strength';
      case 'agi': return 'Agility';
      case 'int': return 'Intelligence';
      case 'all': return 'Universal';
      default: return primaryAttr;
    }
  }
}
