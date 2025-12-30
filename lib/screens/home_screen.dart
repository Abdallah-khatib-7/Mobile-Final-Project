import 'package:flutter/material.dart';
import '../models/lost_item.dart';
import '../services/api_service.dart';
import 'add_items_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lost & Found"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddItemScreen()),
              );
            },
          )
        ],
      ),

      body: FutureBuilder<List<LostItem>>(
        future: ApiService.fetchItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No items found"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(item.title),
                  subtitle:
                  Text("${item.location} • ${item.category}"),
                  trailing: Text(
                    item.status,
                    style: TextStyle(
                      color: item.status == "Lost"
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
