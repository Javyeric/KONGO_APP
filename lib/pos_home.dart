import 'package:flutter/material.dart';
import '../products/products.dart';
import '../models/product.dart';

class POSHomePage extends StatefulWidget {
  const POSHomePage({super.key});

  @override
  State<POSHomePage> createState() => _POSHomePageState();
}

class _POSHomePageState extends State<POSHomePage> {
  String? selectedCategory;
  String? selectedType;

  final Map<Product, int> cart = {};

  // Search
  bool showSearch = false;
  String searchQuery = '';

  List<String> get categories => products.map((p) => p.category).toSet().toList();

  List<String> get types {
    if (selectedCategory != null) {
      return products
          .where((p) => p.category == selectedCategory)
          .map((p) => p.type)
          .toSet()
          .toList();
    } else {
      return products.map((p) => p.type).toSet().toList();
    }
  }

  List<Product> get filteredProducts {
    return products.where((p) {
      final matchesCategory = selectedCategory == null || p.category == selectedCategory;
      final matchesType = selectedType == null || p.type == selectedType;
      final matchesSearch =
          searchQuery.isEmpty || p.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesType && matchesSearch;
    }).toList();
  }

  void addToCart(Product product) {
    setState(() {
      cart.update(product, (value) => value + 1, ifAbsent: () => 1);
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

  double get totalPrice =>
      cart.entries.fold(0, (sum, e) => sum + e.key.price * e.value);

  void showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Checkout'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: cart.entries.map((entry) {
                    return ListTile(
                      title: Text(entry.key.name),
                      subtitle: Text('Qty: ${entry.value}'),
                      trailing: Text('KES ${entry.key.price * entry.value}'),
                    );
                  }).toList(),
                ),
              ),
              const Divider(),
              Text('Total: KES $totalPrice',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  cart.clear();
                });
                Navigator.pop(context);
              },
              child: const Text('Confirm')),
        ],
      ),
    );
  }

  bool isCartMinimized = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Home'),
        actions: [
          IconButton(
            icon: Icon(showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                showSearch = !showSearch;
                if (!showSearch) searchQuery = '';
              });
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SEARCH BAR
          if (showSearch)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search product...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),

          // CATEGORY CHIPS
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              children: [
                ChoiceChip(
                  label: const Text('All Categories'),
                  selected: selectedCategory == null,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = null;
                      selectedType = null;
                    });
                  },
                ),
                const SizedBox(width: 5),
                ...categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selectedCategory == cat,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = cat;
                          selectedType = null;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // TYPE CHIPS
          if (selectedCategory != null)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                children: [
                  ChoiceChip(
                    label: const Text('All Types'),
                    selected: selectedType == null,
                    onSelected: (_) {
                      setState(() {
                        selectedType = null;
                      });
                    },
                  ),
                  const SizedBox(width: 5),
                  ...types.map(
                    (type) => Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: ChoiceChip(
                        label: Text(type),
                        selected: selectedType == type,
                        onSelected: (_) {
                          setState(() {
                            selectedType = type;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(),

          // PRODUCT GRID
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Card(
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: product.image != null
                            ? Image.asset(product.image!, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported, size: 50),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${product.size} | KES ${product.price}'),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => removeFromCart(product),
                                ),
                                Text(cart[product]?.toString() ?? '0'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: Colors.green),
                                  onPressed: () => addToCart(product),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // CART BAR
          if (cart.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  isCartMinimized = !isCartMinimized;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: Colors.blueGrey[800],
                height: isCartMinimized ? 50 : 200,
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Cart: ${cart.length} items',
                            style: const TextStyle(color: Colors.white)),
                        ElevatedButton(
                            onPressed: showCheckoutDialog,
                            child: const Text('Checkout')),
                      ],
                    ),
                    if (!isCartMinimized)
                      Expanded(
                        child: ListView(
                          children: cart.entries.map((entry) {
                            return ListTile(
                              title: Text(entry.key.name, style: const TextStyle(color: Colors.white)),
                              subtitle: Text('Qty: ${entry.value}', style: const TextStyle(color: Colors.white70)),
                              trailing: Text('KES ${entry.key.price * entry.value}', style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}