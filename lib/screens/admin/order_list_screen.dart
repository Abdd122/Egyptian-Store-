
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date formatting

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الطلبات'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد طلبات لعرضها.'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderData = order.data() as Map<String, dynamic>;
              final orderId = order.id;
              final timestamp = orderData['createdAt'] as Timestamp;
              final date = timestamp.toDate();
              final formattedDate = DateFormat('yyyy/MM/dd, hh:mm a').format(date);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text('طلب #${orderId.substring(0, 6)}...'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('العميل: ${orderData['userId']?.substring(0, 6) ?? 'غير معروف'}...'),
                      Text(formattedDate),
                       Text(
                        'الحالة: ${orderData['status'] ?? 'غير محدد'}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(orderData['status'])),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${orderData['totalAmount']?.toStringAsFixed(2) ?? '0.00'} ر.س',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onTap: () {
                    // Navigate to Order Detail Screen
                     context.go('/admin/order-details/$orderId');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
   Color _getStatusColor(String? status) {
    switch (status) {
      case 'قيد المعالجة':
        return Colors.orange;
      case 'تم الشحن':
        return Colors.blue;
      case 'تم التسليم':
        return Colors.green;
      case 'ملغي':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
