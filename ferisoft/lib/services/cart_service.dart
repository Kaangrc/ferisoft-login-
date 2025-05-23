import 'dart:convert';
import 'package:http/http.dart' as http;

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final String baseUrl = 'http://flutter.kodps.com/api';
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Future<List<Map<String, dynamic>>> getBasket() async {
    try {
      print('[CartService] Sepet öğeleri alınıyor...');
      final response = await http.get(
        Uri.parse('$baseUrl/get/basket'),
        headers: _headers,
      );

      print('[CartService] Response Status Code: ${response.statusCode}');
      print('[CartService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> basketItems = json.decode(response.body);
        print('[CartService] Sepet öğeleri: $basketItems');

        if (basketItems.isEmpty) {
          return [];
        }

        // Tüm ürünleri tek seferde al
        final productsResponse = await http.get(
          Uri.parse('$baseUrl/products'),
          headers: _headers,
        );

        if (productsResponse.statusCode == 200) {
          final List<dynamic> products = json.decode(productsResponse.body);
          print('[CartService] Ürünler: $products');

          // Ürünleri ID'ye göre map'le
          final Map<int, dynamic> productMap = {
            for (var product in products) product['id']: product
          };

          // Sepet öğelerini ürün bilgileriyle birleştir
          final List<Map<String, dynamic>> result = basketItems
              .map((item) {
                final productId = item['product_id'] as int;
                final product = productMap[productId];
                print('[CartService] Ürün ID: $productId, Ürün: $product');

                if (product != null) {
                  return {
                    'id': item['id'],
                    'product_id': productId,
                    'quantity': 1,
                    'product': {
                      'id': product['id'],
                      'name': product['product_name'],
                      'description': product['product_description'],
                      'price': product['product_price'],
                    },
                  };
                }
                return null;
              })
              .whereType<Map<String, dynamic>>()
              .toList();

          print('[CartService] Birleştirilmiş sepet verisi: $result');
          return result;
        }
      }
      return [];
    } catch (e) {
      print('[CartService] Sepet alınırken hata oluştu: $e');
      return [];
    }
  }

  Future<bool> addToBasket(int productId, {int quantity = 1}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add/basket'),
        headers: _headers,
        body: json.encode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Sepete eklenirken hata: $e');
      return false;
    }
  }

  Future<bool> clearBasket() async {
    try {
      final basketItems = await getBasket();
      for (var item in basketItems) {
        final productId =
            item['product'] != null ? item['product']['id'] : null;
        if (productId != null) {
          await removeFromBasket(productId);
        }
      }
      return true;
    } catch (e) {
      print('Sepet temizlenirken hata: $e');
      return false;
    }
  }

  Future<bool> removeFromBasket(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/remove/basket/$productId'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Sepetten silinirken hata: $e');
      return false;
    }
  }
}
