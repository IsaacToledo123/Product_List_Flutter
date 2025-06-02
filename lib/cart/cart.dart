import '../models/product.dart';

class Cart {
  static final List<Product> items = [];
  static void add(Product product) => items.add(product);
  static void remove(Product product) => items.remove(product);
  static double get total=>items.fold(0, (sum, item) => sum + item.price);
  }
  
