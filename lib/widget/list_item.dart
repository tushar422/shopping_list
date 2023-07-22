import 'package:flutter/material.dart';
import 'package:shopping_list/model/grocery_item.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.item,
  });

  final GroceryItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        height: 30,
        width: 30,
        color: item.category!.color,
      ),
      title: Text(item.name),
      trailing: Text(item.quantity.toString()),
    );
  }
}
