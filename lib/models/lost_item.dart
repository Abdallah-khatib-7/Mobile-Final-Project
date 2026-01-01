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

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'title': title,
      'location': location,
      'status': status,
      'category': category,
      'description': description ?? '',
    };
  }


  LostItem copyWith({
    String? title,
    String? location,
    String? status,
    String? category,
    String? description,
  }) {
    return LostItem(
      itemId: itemId,
      title: title ?? this.title,
      location: location ?? this.location,
      status: status ?? this.status,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }
}