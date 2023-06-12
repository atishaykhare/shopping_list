import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _itemName = '';
  var _quantity = 1;
  var _selectedCategory = categories[Categories.hygiene]!;
  var _isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https(
          'grocery-app-flutter-2dc06-default-rtdb.asia-southeast1.firebasedatabase.app',
          'shopping-list.json');
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'category': _selectedCategory.title,
            'name': _itemName,
            'quantity': _quantity,
          }));

      if (context.mounted) {
        final Map<String, dynamic> resData = json.decode(response.body);

        Navigator.of(context).pop(
          GroceryItem(
              id: resData['name'],
              name: _itemName,
              quantity: _quantity,
              category: _selectedCategory),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length < 5 ||
                      value.trim().length > 50) {
                    return 'Must Be between 5 to 50 Characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _itemName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                        errorMaxLines: 2,
                      ),
                      initialValue: _quantity.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Quantity Must be greater than 0';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _quantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        value: _selectedCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(category.value.title),
                                ],
                              ),
                            ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedCategory = val!;
                          });
                        }),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _isSending ? () {} : _formKey.currentState!.reset();
                    },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _saveItem,
                    child: _isSending
                        ? const Icon(Icons.circle)
                        : const Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
