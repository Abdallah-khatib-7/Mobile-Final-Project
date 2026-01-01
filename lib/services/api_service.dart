import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lost_item.dart';

class ApiService {
  static const String baseUrl = "http://lostfoundapp.atwebpages.com";

  static Future<List<LostItem>> fetchItems() async {
    final response = await http.get(Uri.parse("$baseUrl/getLostItems.php"));

    if (response.statusCode == 200) {
      try {
        final List data = json.decode(response.body);
        return data.map((e) => LostItem.fromJson(e)).toList();
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception("Failed to parse data");
      }
    } else {
      throw Exception("Failed to load data. Status: ${response.statusCode}");
    }
  }

  static Future<bool> addItem({
    required String title,
    required String location,
    required String status,
    required String category,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/addLostItem.php"),
      body: {
        'title': title,
        'location': location,
        'status': status,
        'category': category,
        'description': description ?? '',
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      return result['success'] == true;
    }
    return false;
  }

// NEW: Update item status (mark as found/lost)
  static Future<bool> updateItemStatus({
    required String itemId,
    required String status,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/updateStatus.php"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'item_id': itemId,
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      return result['success'] == true;
    }
    return false;
  }
}[

file content
end]