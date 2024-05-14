import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_app/data/categories.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/models/grocery_item.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() => _NewItemState();
}

class _NewItemState extends State<NewItemScreen> {
  //creating a GlobalKey to validate the form
  //this key will be used to access the form and validate it, formstate is a class that contains the current state of the form
  //globalkey ensures that even when the widget is rebuilt, the state of the form is preserved, globalkey allows us to access the form state from anywhere in the widget tree
  final formKey = GlobalKey<FormState>();
  //setting the initial values
  var enteredName = '';
  var enteredQuantity = 1;
  var selectedCategory = categories[Categories.vegetables];
  //setting isSending to false, meaning the data is not being saved
  var isSending = false;

  void saveItem() async {
    //validate all the validator functions in the formfields
    //if all the formfields are valid, the save function will be called
    if (formKey.currentState!.validate()) {
      //save the form fields, this triggers the onSaved function in each form field
      formKey.currentState!.save();
      //sending the data to the database, by using the post method
      //creating the url to the database
      setState(() {
        isSending =
            true; //setting isSending to true after the form is saved to show the user that the data is being saved
      });
      final url = Uri.https(
          //takes in the url and the path to the database, which we can name anything we want
          'flutter-prep-63a02-default-rtdb.firebaseio.com',
          'shopping-app.json');
      //we have to wait for the post method to be completed, so we use async and await which gives us access to the response
      //afte we have sent the post request, we get a response from the server when the data is saved and we can use this response to check if the data was saved successfully
      //basically, we are sending a post request (sending data to the server) to the database to store data in the database, when said data is stored, we get a response from the server and we store that response in the response variable
      final response = await http.post(
        url,
        //telling firebase that we are sending json data
        headers: {
          'Content-Type': 'application/json',
        },
        //converting the data we want to send  to json format by using json.encode
        body: json.encode(
          {
            'name': enteredName,
            'quantity': enteredQuantity,
            'category': selectedCategory!.name,
          },
        ),
      );
      //converting the response body to a map
      final resData = json.decode(response.body);
      //mounted is a property of the state class, which is true if the widget is currently in the widget tree, in this case, we are checking if the widget is still mounted before popping the screen
      if (!context.mounted) return;
      //popping the screen after the data is saved
      Navigator.pop(
          context,
          GroceryItem(
              //using the id that we get from the response to set the id of the grocery item
              id: resData['name'],
              name: enteredName,
              quantity: enteredQuantity,
              category: selectedCategory!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          //to validate all the form fields, we need to use a GlobalKey
          key: formKey,
          child: Column(
            children: [
              //instead of Textfield widget used before
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                //validator function to check if the input is valid
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters';
                  }
                  //if the input is valid, return null
                  return null;
                },
                onSaved: (value) {
                  //this function will be called when the form is saved
                  //setting the enteredName to the value that the user entered in the textfield
                  enteredName = value!;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      maxLength: 3,
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      initialValue: enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        //setting the enteredQuantity to the value that the user entered in the textfield
                        enteredQuantity = int.parse(value!);
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                        //value is the value that is currently selected in the dropdown
                        value: selectedCategory,
                        items: [
                          //entries converts the map into a list of key-value pairs, which we can then loop through, as we cant loop through a map directly
                          for (final category in categories.entries)
                            DropdownMenuItem(
                                //value is what we will get when the user selects the item, and is going to be passed to the onChanged function
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      //value is the key of the map entry, because we used categories.entries
                                      color: category.value.color,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(category.value.name),
                                  ],
                                ))
                        ],
                        onChanged: (value) {
                          //this function will be called when the user selects an item
                          //setting the selectedCategory to the value that the user selected
                          setState(() {
                            selectedCategory = value!;
                          });
                        }),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      //disabling the reset button when the data is being saved so that the user cannot reset the form while the data is being saved
                      onPressed: isSending
                          ? null
                          : () {
                              //reset the form
                              formKey.currentState!.reset();
                            },
                      child: const Text('Reset')),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      //disabling the add item button when the data is being saved so that the user cannot add the same item multiple times
                      //also addung na loading spinner to show the user that the data is being saved
                      onPressed: isSending ? null : saveItem,
                      child: isSending
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Add Item'))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
