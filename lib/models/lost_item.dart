class LostItem {
  final String itemId;
  final String title;
  final String location;
  final String status;
  final String category;
  final String? description;

  LostItem({
    required this.itemId,
    required this.title,
    required this.location,
    required this.status,
    required this.category,
    this.description,
  });

  factory LostItem.fromJson(Map<String, dynamic> json) {
    return LostItem(
      itemId: json['item_id'].toString(),
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? '',
      category: json['category'] ?? '',
      description: json['description'],
    );
  }
}