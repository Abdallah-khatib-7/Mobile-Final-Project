import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lost_item.dart';

class ApiService {
  static const String url =
      "http://lostfoundapp.atwebpages.com/getLostItems.php";

  static Future<List<LostItem>> fetchItems() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => LostItem.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load data");
    }
  }
}
