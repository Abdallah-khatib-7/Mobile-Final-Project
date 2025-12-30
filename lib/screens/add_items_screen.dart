import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  File? image;

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  Future uploadItem() async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("http://lostfoundapp.atwebpages.com/addLostItem.php"),
    );

    request.fields['title'] = titleController.text;
    request.fields['location'] = locationController.text;
    request.fields['status'] = "Lost";
    request.fields['category'] = "1";

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image!.path,
      ),
    );

    await request.send();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Item")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "Location"),
            ),
            const SizedBox(height: 10),



            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadItem,
              child: const Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}
