import 'package:flutter/material.dart';
import '../cart/cart.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = Cart.items;
    return Scaffold(
      appBar: AppBar(title: Text("carrito de compras")),
      body:
          items.isEmpty
              ? Center(child: Text("El carrito esta vacio"))
              : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final product = items[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                  );
                },
              ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('total:\$${Cart.total.toStringAsFixed(2)}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),

      ),
    );
  }
}
