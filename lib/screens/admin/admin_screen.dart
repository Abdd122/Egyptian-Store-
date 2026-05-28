
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          AdminCard(
            icon: Icons.add_shopping_cart,
            title: 'إضافة منتج جديد',
            subtitle: 'إدخال منتج جديد إلى الكتالوج',
            onTap: () => context.go('/admin/add-product'),
          ),
          const Divider(),
          AdminCard(
            icon: Icons.list_alt,
            title: 'عرض المنتجات',
            subtitle: 'تعديل وحذف المنتجات الحالية',
            onTap: () => context.go('/admin/product-list'),
          ),
          const Divider(),
          AdminCard(
            icon: Icons.view_list,
            title: 'عرض الطلبات',
            subtitle: 'عرض طلبات العملاء وتفاصيلها',
            onTap: () => context.go('/admin/order-list'), // Navigate to the order list screen
          ),
        ],
      ),
    );
  }
}

class AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const AdminCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
    );
  }
}
