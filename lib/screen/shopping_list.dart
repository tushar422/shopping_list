import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/model/grocery_item.dart';
import 'package:shopping_list/screen/new_item_sheet.dart';
import 'package:shopping_list/widget/list_item.dart';
import 'package:http/http.dart' as http;

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;
  bool _isSending = false;

  String? _errorMessage;

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = (_isLoading)
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : (_groceryItems.isEmpty)
            ? const Center(
                child: Text('Your shopping list is empty!'),
              )
            : ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    key: ValueKey(_groceryItems[index]),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListItem(item: _groceryItems[index]),
                    ),
                    onDismissed: (direction) {
                      _delete(_groceryItems[index], index);
                    },
                  );
                },
                itemCount: _groceryItems.length,
              );
    if (_errorMessage != null) {
      content = Center(
        child: Text(_errorMessage!),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(onPressed: _loadItems, icon: const Icon(Icons.refresh))
        ],
      ),
      body: content,
      floatingActionButton: FloatingActionButton(
        onPressed: (_isSending) ? null : _addItem,
        child: (_isSending)
            ? const CircularProgressIndicator()
            : const Icon(Icons.add),
      ),
    );
  }

  void _delete(GroceryItem item, int index) async {
    setState(() {
      _groceryItems.removeAt(index);
    });
    final url = Uri.https(
      'billing-d500e-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list/${item.id}.json',
    );
    final response = await http.delete(url);
    if (response.statusCode > 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${item.name} couldn\'t be removed from the shopping list.'),
        ),
      );
      setState(() {
        _groceryItems.insert(index, item);
      });
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} removed from the shopping list.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _addItem(itemToAdd: item);
          },
        ),
      ),
    );
  }

  void _addItem({GroceryItem? itemToAdd}) async {
    final item = (itemToAdd == null)
        ? await showModalBottomSheet(
            isDismissible: true,
            isScrollControlled: true,
            context: context,
            showDragHandle: true,
            enableDrag: true,
            builder: (ctx) {
              return const NewItem();
            },
          )
        : {
            'name': itemToAdd.name,
            'quantity': itemToAdd.quantity,
            'category': itemToAdd.category,
          };
    if (item == null) return;
    setState(() {
      _isSending = true;
    });

    final url = Uri.https(
      'billing-d500e-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list.json',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': item['name'],
        'quantity': item['quantity'],
        'category': item['category'].name,
      }),
    );
    if (response.statusCode > 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${item['name']} couldn\'t be added to the shopping list.'),
        ),
      );
      setState(() {
        _isSending = false;
      });
    }
    final responseId = jsonDecode(response.body)['name'];
    final gItem = GroceryItem(
      id: responseId,
      name: item['name'],
      quantity: item['quantity'],
      category: item['category'],
    );

    setState(() {
      _groceryItems.add(gItem);
      _isSending = false;
    });
  }

  void _loadItems() async {
    setState(() {
      _isLoading = true;
    });
    final url = Uri.https(
      'billing-d500e-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list.json',
    );
    final response = await http.get(
      url,
      // headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode > 400) {
      setState(() {
        _errorMessage = "Some Error Occured";
      });
    }
    List<GroceryItem> loadedData = [];
    if (response.body == 'null') {
      setState(() {
        _groceryItems = loadedData;
        _isLoading = false;
      });
      return;
    }
    final Map<String, dynamic> data = json.decode(response.body);
    for (final item in data.entries) {
      loadedData.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: categories.values.firstWhere(
            (element) => element.name == item.value['category'],
          ),
          // categories.values.firstWhere((element) {
          //   if (element.name == item.value['category']) return true;
          //   return false;
          // })
        ),
      );
    }
    setState(() {
      _groceryItems = loadedData;
      _isLoading = false;
    });
  }
}
