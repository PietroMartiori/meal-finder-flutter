class Category {
  const Category({required this.strCategory});

  final String strCategory;

  factory Category.fromJson(Map<String, dynamic> json) {
    String text(Object? value) => value?.toString().trim() ?? '';

    return Category(strCategory: text(json['strCategory']));
  }
}
