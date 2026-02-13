class CategoryRequest {
  final String name;
  final String type;
  final String icon;
  final String color;

  CategoryRequest({
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "type": type,
    "icon": icon,
    "color": color,
  };
}
