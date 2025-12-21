// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _size = '';
  double _price = 0.0;
  String _category = 'Liquor'; // Default
  String _type = 'Whiskey'; // Default
  String _imageUrl = '';

  final List<String> _categories = ['All', 'Soft Drink', 'Liquor', 'Essentials'];
  final List<String> _liquorTypes = ['All', 'Spirit', 'Whiskey', 'Gin', 'Vodka', 'Beer'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Drink/Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => _name = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Size (e.g., 750ml)'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => _size = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price (KES)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Required';
                    if (double.tryParse(value) == null) return 'Invalid number';
                    return null;
                  },
                  onSaved: (value) => _price = double.parse(value!),
                ),
                const SizedBox(height: 16),
// For category
DropdownButtonFormField<String>(
  initialValue: _category,  // <-- Change to initialValue
  decoration: const InputDecoration(labelText: 'Category'),
  items: _categories.map((cat) {
    return DropdownMenuItem(value: cat, child: Text(cat));
  }).toList(),
  onChanged: (value) => setState(() => _category = value!),
),

// For type (inside if (_category == 'Liquor'))
DropdownButtonFormField<String>(
  initialValue: _type,  // <-- Change to initialValue
  decoration: const InputDecoration(labelText: 'Type'),
  items: _liquorTypes.map((type) {
    return DropdownMenuItem(value: type, child: Text(type));
  }).toList(),
  onChanged: (value) => setState(() => _type = value!),
),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Image URL (optional)'),
                  keyboardType: TextInputType.url,
                  onSaved: (value) => _imageUrl = value ?? '',
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitProduct,
                    child: const Text('Add Product'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

void _submitProduct() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': _name,
        'size': _size,
        'price': _price,
        'category': _category,
        'type': _type,
        'image': _imageUrl.isNotEmpty ? _imageUrl : null,
      });

      // Guard with mounted check
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );

      if (!mounted) return;

      Navigator.pop(context);  // Safe to pop
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
}