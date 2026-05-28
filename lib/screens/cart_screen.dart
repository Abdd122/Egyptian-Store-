
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/cart_provider.dart';
import 'package:myapp/widgets/cart_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  Future<void> _placeOrder(CartProvider cart) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب عليك تسجيل الدخول أولاً لإتمام عملية الشراء.'),
          backgroundColor: Colors.red,
        ),
      );
      context.go('/login');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'totalAmount': cart.totalAmount,
        'createdAt': Timestamp.now(),
        'products': cart.items.values.map((cartItem) => {
          'productId': cartItem.product.id,
          'name': cartItem.product.name,
          'quantity': cartItem.quantity,
          'price': cartItem.product.price,
        }).toList(),
        'status': 'قيد المعالجة', // Initial order status
      });

      cart.clear();

      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال طلبك بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      }

    } catch (error) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء إرسال الطلب: $error'),
            backgroundColor: Colors.red,
          ),
        );
       }
    } finally {
       if (mounted) {
        setState(() {
          _isLoading = false;
        });
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('عربة التسوق'),
      ),
      body: cart.itemCount == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'عربة التسوق فارغة!',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/store'),
                    child: const Text('اذهب إلى المتجر'),
                  )
                ],
              ),
            )
          : Column(
              children: <Widget>[
                Card(
                  margin: const EdgeInsets.all(15),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          'الإجمالي',
                          style: TextStyle(fontSize: 20),
                        ),
                        const Spacer(),
                        Chip(
                          label: Text(
                            '${cart.totalAmount.toStringAsFixed(2)} ر.س',
                            style: TextStyle(
                              color: Theme.of(context).primaryTextTheme.titleLarge?.color,
                            ),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                       _isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: CircularProgressIndicator(),
                            )
                          : TextButton(
                          onPressed: (cart.totalAmount <= 0)
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('تأكيد الشراء'),
                                      content: const Text('هل أنت متأكد من رغبتك في إتمام عملية الشراء؟'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('لا'),
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('نعم'),
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                            _placeOrder(cart);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                          child: const Text('إتمام الشراء'),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) => CartListItem(
                      id: cart.items.values.toList()[i].product.id,
                      productId: cart.items.keys.toList()[i],
                      price: cart.items.values.toList()[i].product.price,
                      quantity: cart.items.values.toList()[i].quantity,
                      name: cart.items.values.toList()[i].product.name,
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
