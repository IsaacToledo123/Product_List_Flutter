import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  final String _baseUrl = 'https://fakestoreapi.com';

 Future<List<Product>> getProducts() async {
  final response = await http.get(Uri.parse('$_baseUrl/products'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => Product.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load products');
  }
}


  Future<Product> getProductById(int id) async {
  final response = await http.get(Uri.parse('$_baseUrl/products/$id'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return Product.fromJson(data);
  } else {
    throw Exception('Failed to load product');
  }
}


  Future<dynamic> createCart(Map<String, dynamic> cartData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/carts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cartData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create cart');
    }
  }
  Future<dynamic> getCartById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/carts/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load cart');
    }
  }
}