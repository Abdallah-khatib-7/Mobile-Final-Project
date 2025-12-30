class LostItem {
  final String itemId;
  final String title;
  final String location;
  final String status;
  final String category;

  LostItem({
    required this.itemId,
    required this.title,
    required this.location,
    required this.status,
    required this.category,
  });

  factory LostItem.fromJson(Map<String, dynamic> json) {
    return LostItem(
      itemId: json['item_id'],
      title: json['title'],
      location: json['location'],
      status: json['status'],
      category: json['category'],
    );
  }
}
