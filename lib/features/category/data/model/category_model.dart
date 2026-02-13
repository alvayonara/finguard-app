class CategoryModel {
  final int id;
  final String name;
  final String type;
  final String icon;
  final String color;
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.isDefault,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      icon: json['icon'] ?? 'category',
      color: json['color'] ?? '#9E9E9E',
      isDefault: json['isDefault'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
