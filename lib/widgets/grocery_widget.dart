import 'package:flutter/material.dart';
import 'package:shopping_app/models/grocery_item.dart';

class Grocery extends StatelessWidget {
  const Grocery({super.key, required this.items});

  final GroceryItem items;
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(items.name),
        leading: Container(
          width: 30,
          height: 30,
          color: items.category.color,
        ),
        trailing: Text(
          items.quantity.toString(),
          style: const TextStyle(fontSize: 15),
        ));
  }
}
