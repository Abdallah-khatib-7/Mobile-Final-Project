import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lost_item.dart';

class ApiService {
  static const String baseUrl = "http://lostfoundapp.atwebpages.com";

  static Future<List<LostItem>> fetchItems() async {
    print('DEBUG: Fetching items from $baseUrl/getLostItems.php');

    try {
      final response = await http.get(Uri.parse("$baseUrl/getLostItems.php"));

      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final List data = json.decode(response.body);
          print('DEBUG: Parsed ${data.length} items');
          return data.map((e) => LostItem.fromJson(e)).toList();
        } catch (e) {
          print('ERROR parsing JSON: $e');
          throw Exception("Failed to parse data: $e");
        }
      } else {
        throw Exception("Failed to load data. Status: ${response.statusCode}");
      }
    } catch (e) {
      print('ERROR in fetchItems: $e');
      rethrow;
    }
  }

  static Future<bool> addItem({
    required String title,
    required String location,
    required String status,
    required String category,
    String? description,
  }) async {
    print('DEBUG: Adding item - title: $title, location: $location');

    try {
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

      print('DEBUG: Add item response status: ${response.statusCode}');
      print('DEBUG: Add item response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      print('ERROR adding item: $e');
      return false;
    }
  }

  // Update item status
  static Future<Map<String, dynamic>> updateItemStatus({
    required String itemId,
    required String status,
  }) async {
    print('DEBUG: Updating item $itemId to status: $status');
    print('DEBUG: URL: $baseUrl/updateStatus.php');

    try {
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

      print('DEBUG: Update response status: ${response.statusCode}');
      print('DEBUG: Update response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final result = json.decode(response.body);
          print('DEBUG: Parsed update result: $result');

          return {
            'success': result['success'] == true,
            'message': result['message'] ?? 'Unknown response',
            'data': result
          };
        } catch (e) {
          print('ERROR parsing update response: $e');
          return {
            'success': false,
            'message': 'Failed to parse server response: $e'
          };
        }
      } else {
        print('ERROR: Server returned status ${response.statusCode}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('EXCEPTION during update: $e');
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }
}