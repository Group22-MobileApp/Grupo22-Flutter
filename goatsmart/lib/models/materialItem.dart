
class MaterialItem {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final String owner;

  MaterialItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.owner,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'images': images,
      'owner': owner,
    };
  }

  factory MaterialItem.fromMap(Map<String, dynamic> map) {
    return MaterialItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      price: map['price'].toDouble(),
      images: List<String>.from(map['images']),
      owner: map['owner'],
    );
  }
}
