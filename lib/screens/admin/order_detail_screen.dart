
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  String? _currentStatus;
  bool _isUpdating = false;

  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() {
      _isUpdating = true;
    });
    try {
      await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
        'status': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث حالة الطلب بنجاح'), backgroundColor: Colors.green),
      );
      setState(() {
        _currentStatus = newStatus;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحديث الحالة: $e')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطلب #${widget.orderId.substring(0, 6)}...'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('لم يتم العثور على الطلب.'));
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final products = (orderData['products'] as List).cast<Map<String, dynamic>>();
          final timestamp = orderData['createdAt'] as Timestamp;
          final formattedDate = DateFormat('yyyy/MM/dd, hh:mm a').format(timestamp.toDate());

          if (_currentStatus == null) {
            _currentStatus = orderData['status'] ?? 'غير محدد';
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildInfoCard('معلومات الطلب', {
                'رقم الطلب': widget.orderId,
                'تاريخ الطلب': formattedDate,
                'المبلغ الإجمالي': '${orderData['totalAmount']?.toStringAsFixed(2)} ر.س',
                'معرف العميل': orderData['userId'] ?? 'غير متوفر',
              }),
              const SizedBox(height: 16),
              _buildProductsCard('المنتجات المطلوبة', products),
              const SizedBox(height: 16),
              _buildStatusCard('حالة الطلب'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, Map<String, String> data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            ...data.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Flexible(child: Text(entry.value, textAlign: TextAlign.end)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsCard(String title, List<Map<String, dynamic>> products) {
    return Card(
       elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            ...products.map((product) => ListTile(
              title: Text(product['name'] ?? 'بلا اسم'),
              subtitle: Text('الكمية: ${product['quantity']}'),
              trailing: Text('${(product['price'] as num).toStringAsFixed(2)} ر.س'),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title) {
    final List<String> statuses = ['قيد المعالجة', 'تم الشحن', 'تم التسليم', 'ملغي'];

    return Card(
       elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Text('الحالة الحالية:', style: TextStyle(fontWeight: FontWeight.bold)),
                   Chip(
                    label: Text(_currentStatus ?? '...'),
                    backgroundColor: _getStatusColor(_currentStatus).withOpacity(0.2),
                    labelStyle: TextStyle(color: _getStatusColor(_currentStatus), fontWeight: FontWeight.bold),
                  ),
                ],
            ),
             const SizedBox(height: 16),
            const Text('تحديث الحالة إلى:', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: _currentStatus,
              items: statuses.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                if(newValue != null) {
                  _updateOrderStatus(newValue);
                }
              },
            ),
             if (_isUpdating) const Center(child: Padding(
               padding: EdgeInsets.all(8.0),
               child: CircularProgressIndicator(),
             )),
          ],
        ),
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
