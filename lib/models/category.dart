class Category {
  const Category({
    required this.idCategory,
    required this.strCategory,
    required this.strCategoryThumb,
    required this.strCategoryDescription,
  });

  final String idCategory;
  final String strCategory;
  final String strCategoryThumb;
  final String strCategoryDescription;

  factory Category.fromJson(Map<String, dynamic> json) {
    String text(Object? value) => value?.toString().trim() ?? '';

    return Category(
      idCategory: text(json['idCategory']),
      strCategory: text(json['strCategory']),
      strCategoryThumb: text(json['strCategoryThumb']),
      strCategoryDescription: text(json['strCategoryDescription']),
    );
  }
}
