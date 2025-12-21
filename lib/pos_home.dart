// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kongo/utils/receipt_generator.dart';
import 'package:kongo/models/product.dart';
import 'package:kongo/screens/add_product_screen.dart';

class POSHomePage extends StatefulWidget {
  const POSHomePage({super.key});

  @override
  _POSHomePageState createState() => _POSHomePageState();
}

class _POSHomePageState extends State<POSHomePage> {
  String selectedCategory = 'All';
  String selectedType = 'All';
  Map<Product, int> cart = {};
  String searchQuery = '';
  bool showCart = true;

  List<Product> filteredProducts(List<Product> allProducts) {
    return allProducts.where((product) {
      final matchesCategory = selectedCategory == 'All' || product.category == selectedCategory;
      final matchesType = selectedType == 'All' || product.type == selectedType;
      final matchesSearch = product.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesType && matchesSearch;
    }).toList();
  }

  void addToCart(Product product) {
    setState(() {
      if (cart.containsKey(product)) {
        cart[product] = cart[product]! + 1;
      } else {
        cart[product] = 1;
      }
    });
  }

  void removeFromCart(Product product) {
    setState(() {
      if (cart.containsKey(product)) {
        if (cart[product]! > 1) {
          cart[product] = cart[product]! - 1;
        } else {
          cart.remove(product);
        }
      }
    });
  }

  double get total {
    return cart.entries
        .map((entry) => entry.key.price * entry.value)
        .fold(0.0, (previousSum, element) => previousSum + element);
  }

  void checkout() async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    await ReceiptGenerator.generateReceipt(
      cartItems: cart,
      total: total,
      date: formattedDate,
    );

    if (!mounted) return;
    setState(() {
      cart.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Home'),
        actions: [
          IconButton(icon: const Icon(Icons.receipt_long), onPressed: checkout),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
        },
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                categoryChip('All'),
                categoryChip('Soft Drink'),
                categoryChip('Liquor'),
                categoryChip('Essentials'),
              ],
            ),
          ),
          if (selectedCategory == 'Liquor')
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  liquorTypeChip('All'),
                  liquorTypeChip('Spirit'),
                  liquorTypeChip('Whiskey'),
                  liquorTypeChip('Gin'),
                  liquorTypeChip('Vodka'),
                  liquorTypeChip('Beer'),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No products found. Add some in Firestore!'));
                }

                final allProducts = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Product.fromJson(data);
                }).toList();

                final filtered = filteredProducts(allProducts);

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return Card(
                      elevation: 4,
                      child: InkWell(
                        onTap: () => addToCart(product),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (product.image != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.image!,
                                  height: 80,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 80),
                                ),
                              )
                            else
                              const Icon(Icons.image_not_supported, size: 80),
                            const SizedBox(height: 8),
                            Text(product.name, textAlign: TextAlign.center),
                            Text(product.size),
                            Text('KES ${product.price.toStringAsFixed(0)}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  showCart = !showCart;
                });
              },
              icon: Icon(showCart ? Icons.expand_more : Icons.expand_less),
              label: Text(showCart ? 'Minimize Cart' : 'Expand Cart'),
            ),
          ),
          if (showCart)
            Container(
              color: Colors.grey[200],
              height: 300,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const Text(
                    'Cart',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView(
                      children: cart.entries.map((entry) {
                        final product = entry.key;
                        final quantity = entry.value;
                        return ListTile(
                          title: Text('${product.name} (${product.size})'),
                          subtitle: Text(
                            'KES ${(product.price * quantity).toStringAsFixed(2)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => removeFromCart(product),
                              ),
                              Text(quantity.toString()),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => addToCart(product),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('KES ${total.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: checkout,
                    child: const Text('Checkout'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget categoryChip(String category) {
    final isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            selectedCategory = selected ? category : 'All';
            selectedType = 'All';
          });
        },
      ),
    );
  }

  Widget liquorTypeChip(String type) {
    final isSelected = selectedType == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(type),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            selectedType = selected ? type : 'All';
          });
        },
      ),
    );
  }
}