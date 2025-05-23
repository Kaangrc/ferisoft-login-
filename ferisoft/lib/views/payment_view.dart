import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final CartService _cartService = CartService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    try {
      final items = await _cartService.getBasket();
      print('[PaymentView] Sepet içeriği: $items');
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      print('[PaymentView] Sepet yüklenirken hata: $e');
      setState(() => _isLoading = false);
    }
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in _cartItems) {
      if (item['product'] != null) {
        total += (item['product']['price'] as num) * (item['quantity'] as num);
      }
    }
    return total;
  }

  Future<void> _completeOrder() async {
    try {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Sipariş Tamamlandı'),
          content:
              Text('Toplam tutar: ${_calculateTotal().toStringAsFixed(2)} TL'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
      await _cartService.clearBasket();
      _loadCart();
    } catch (e) {
      print('[PaymentView] Sipariş tamamlanırken hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sipariş tamamlanırken bir hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sepetim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCart,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? const Center(child: Text('Sepetiniz boş'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          final product = item['product'];
                          if (product == null) return const SizedBox.shrink();

                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(product['name'] ?? 'Ürün Adı Yok'),
                              subtitle: Text(
                                'Fiyat: ${product['price']} TL x ${item['quantity']} = ${(product['price'] as num) * (item['quantity'] as num)} TL',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await _cartService
                                      .removeFromBasket(item['id']);
                                  _loadCart();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Toplam Tutar:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_calculateTotal().toStringAsFixed(2)} TL',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _cartItems.isEmpty ? null : _completeOrder,
                          child: const Text('Siparişi Tamamla'),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
