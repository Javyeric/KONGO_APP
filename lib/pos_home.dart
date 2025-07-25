import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kongo/data/products.dart';
import 'package:kongo/utils/receipt_generator.dart';
import 'models/product.dart';

class POSHomePage extends StatefulWidget {
  @override
  POSHomePageState createState() => POSHomePageState();
}

class POSHomePageState extends State<POSHomePage> {
  final List<Product> allProducts = products;
  String selectedCategory = 'All';
  String selectedType = 'All';
  Map<Product, int> cart = {};
  String searchQuery = '';
  bool showCart = true; // toggle state

  List<Product> get filteredProducts {
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
        .fold(0.0, (sum, element) => sum + element);
  }

  void checkout() async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    await ReceiptGenerator.generateReceipt(
      cartItems: cart,
      total: total,
      date: formattedDate,
    );

    setState(() {
      cart.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('POS Home'),
        actions: [
          IconButton(icon: Icon(Icons.receipt_long), onPressed: checkout),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
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
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category filter
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

          // Liquor sub-type buttons
          if (selectedCategory == 'Liquor')
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(vertical: 4),
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

          // Product grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8),
              itemCount: filteredProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Card(
                  elevation: 4,
                  child: InkWell(
                    onTap: () => addToCart(product),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (product.image != null)
                          Image.asset(product.image!, height: 80),
                        Text(product.name),
                        Text('${product.size}'),
                        Text('KES ${product.price.toStringAsFixed(0)}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Toggle Cart View Button
          Container(
            padding: EdgeInsets.symmetric(vertical: 4),
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

          // Cart
          if (showCart)
            Container(
              color: Colors.grey[200],
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    'Cart',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...cart.entries.map((entry) {
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
                            icon: Icon(Icons.remove),
                            onPressed: () => removeFromCart(product),
                          ),
                          Text(quantity.toString()),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => addToCart(product),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('KES ${total.toStringAsFixed(2)}'),
                    ],
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: checkout,
                    child: Text('Checkout'),
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
