import 'package:shopping_app/models/grocery_item.dart';
import 'package:shopping_app/data/categories.dart';

final groceryItems = [
  GroceryItem(
      id: 'a',
      name: 'Milk',
      quantity: 1,
      category: categories[Categories.dairy]!),
  GroceryItem(
      id: 'b',
      name: 'Bananas',
      quantity: 5,
      category: categories[Categories.fruit]!),
  GroceryItem(
      id: 'c',
      name: 'Beef Steak',
      quantity: 1,
      category: categories[Categories.meat]!),
  GroceryItem(
      id: 'd',
      name: 'Pasta',
      quantity: 2,
      category: categories[Categories.carbs]!),
];