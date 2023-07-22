import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/model/category.dart';
import 'package:shopping_list/util/validator.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  String _enteredName = '';
  String _enteredQuantity = '1';
  Category _selectedCategory = categories[Categories.convenience]!;

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(
        context,
        {
          'name': _enteredName,
          'quantity': int.parse(_enteredQuantity),
          'category': _selectedCategory,
        },
      );
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _enteredName,
              maxLength: 50,
              decoration: const InputDecoration(
                label: Text('Name'),
                border: OutlineInputBorder(),
              ),
              validator: nameValidator,
              onSaved: (newValue) {
                _enteredName = newValue!;
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                      initialValue: _enteredQuantity,
                      validator: quantityValidator,
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (newValue) {
                        _enteredQuantity = (newValue!);
                      }),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: DropdownButtonFormField(
                    value: _selectedCategory,
                    items: [
                      for (final c in categories.entries)
                        DropdownMenuItem(
                          value: c.value,
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                color: c.value.color,
                              ),
                              const SizedBox(width: 20),
                              Text(c.value.name),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _resetForm,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _saveForm,
                  child: const Text('   Save   '),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
