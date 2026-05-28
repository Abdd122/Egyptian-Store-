
import 'package:flutter/foundation.dart';
import 'package:myapp/models/cart_item.dart';
import 'package:myapp/models/product.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};
  final String? userId;

  CartProvider(this.userId, List<CartItem> initialItems, String id) {
    _items = {for (var item in initialItems) item.product.id: item};
  }

  Map<String, CartItem> get items => {..._items};

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          product: product,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  // This will be used to avoid clearing the cart on logout
  void clearOnSignOut() {
    if (userId == null) {
      _items = {};
      notifyListeners();
    }
  }
}
