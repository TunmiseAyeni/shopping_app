import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/models/grocery_item.dart';
import 'package:shopping_app/screens/new_item_screen.dart';
import 'package:shopping_app/widgets/grocery_widget.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  //setting the initial value of isLoading to true, meaning the data is being fetched
  var isLoading = true;
  String? _error;
  List<GroceryItem> _groceryItems = [];
  //using initstate to send the request to fetch the data when the screen is loaded for the first time
  @override
  void initState() {
    loadItems();
    super.initState();
  }

  void loadItems() async {
    //sending a get request to the database to get/fetch the data that was saved
    //creating the url
    final url = Uri.https(
        //takes in the url and the path to the database, which we can name anything we want
        'flutter-prep-63a02-default-rtdb.firebaseio.com',
        'shopping-app.json');
    //getting the data from the database
    //we dont add a body to the get request because we are not sending any data to the database
    //the response will contain the fetched data from the database

//using the try catch block to catch any errors that may occur when sending the get request, we wrap the code in the try block and if there is an error, we catch the error in the catch block
//try catch is mainly used to handle something like missing internet connection, server down, etc
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode >= 400) {
        //using setstate to update the error message on the screen
        setState(() {
          _error =
              'An error occurred: ${response.statusCode} ${response.reasonPhrase}';
        });
      }
      //handling the case where the response body is null i.e there is no data in the database
      if (response.body == 'null') {
        setState(() {
          //the loading spinner will be removed if the data is null
          isLoading = false;
        });
        return;
      }
      //listData is a map that contains a key value pair, the key is a string and the value is a map that contains a key value pair, the key is a string and the value is dynamic
      final Map<String, dynamic> listData =
          //converting the json object body to a map
          json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      //converting the listdata to a list of grocery items by looping through the listdata map
      for (final item in listData.entries) {
        //getting the category object from the categories map by using the name of the category title
        //firstwhere is a method that returns the first element that satisfies the condition
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.name == item.value['category'])
            .value;
        //adding the fetched data to the loadedItems list
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            //we only have the name of the category in the database, so we are using the name to get the category object from the categories map
            category: category,
          ),
        );
      }
      //setting the state of the _groceryItems list to the loadedItems list
      //setting isLoading to false after the data is fetched meaning the data has been fetched
      setState(() {
        _groceryItems = loadedItems;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong, Please try again later!';
      });
    }

    //checking if the status code of the response is greater than or equal to 400, if it is, we are throwing an error
  }

  void addItem() async {
    final newItem = await Navigator.push<GroceryItem>(context,
        MaterialPageRoute(builder: (context) => const NewItemScreen()));
    //if the user uses the back button or the back button on the app bar, the newItem will be null
    if (newItem == null) {
      return;
      //but if the user presses the save button, the newItem will be added to the list
    } else {
      setState(() {
        _groceryItems.add(newItem);
      });
    }
    //using the loadItems function to get the data from the database when the user adds a new item, we didnt do it directly because we want to send the http request to fetch the data when the screen is loaded as well not only when the user adds a new item
    //avoiding the extra get request by passing the data directly from the new item screen to the first screen
    // loadItems();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(
        'No Groceries Added Yet!',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (context, index) {
            return Dismissible(
                key: ValueKey(_groceryItems[index].id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: const Icon(Icons.delete),
                ),
                //removing the item from the list when the user swipes the item to the right
                onDismissed: (right) async {
                  final removedItem = _groceryItems[index];
                  setState(() {
                    _groceryItems.removeAt(index);
                  });
                  final url = Uri.https(
                      //takes in the url and the path to the database, which we can name anything we want
                      'flutter-prep-63a02-default-rtdb.firebaseio.com',
                      'shopping-app/${removedItem.id}.json'); //targeting the specific item to delete
                  final response = await http.delete(url);
                  //checking if there is an error, if there is, we undo the deletion
                  if (response.statusCode >= 400) {
                    setState(() {
                      //adding the item back to the list if there is an error
                      _groceryItems.insert(index, removedItem);
                    });
                  }
                },
                child: Grocery(items: _groceryItems[index]));
          });
    }
    if (isLoading) {
      //adding a loading spinner when the data is being fetched
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_error != null) {
      //displaying an error message if there is an error
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(' Your Groceries'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: addItem,
            )
          ],
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: content);
  }
}
