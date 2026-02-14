class CategoryInfo {
  final int id;
  final String name;
  final String icon;
  final String color;

  CategoryInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      id: json['id'],
      name: json['name'] ?? '',
      icon: json['icon'] ?? 'category',
      color: json['color'] ?? '#9E9E9E',
    );
  }
}
