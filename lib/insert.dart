import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InsertData extends StatefulWidget {
  const InsertData({super.key});

  @override
  State<InsertData> createState() => _InsertDataState();
}

class _InsertDataState extends State<InsertData> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Insert Data")),
      body: Column(
        children: [
          TextField(
              controller: nameController,
              decoration: InputDecoration(border: OutlineInputBorder())),
          TextField(
              controller: ageController,
              decoration: InputDecoration(border: OutlineInputBorder())),
          ElevatedButton(
              onPressed: () {
                if (nameController.text.length > 3 &&
                    ageController.text.length > 0) {
                  addData();
                }
              },
              child: Text("Insert Data"))
        ],
      ),
    );
  }

  void addData() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users.add({
      'name': nameController.text,
      'age': int.parse(ageController.text),
    });
  }
}
