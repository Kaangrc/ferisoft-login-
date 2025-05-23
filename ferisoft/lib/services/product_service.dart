import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final String baseUrl = 'http://flutter.kodps.com/api';
  String? _token;

  void setToken(String token) {
    _token = token;
    print('[ProductService] Token ayarlandı: $token');
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<List<ProductModel>> getProducts() async {
    try {
      print('[ProductService] Ürünler alınıyor...');
      print('[ProductService] Headers: $_headers');

      final response = await http.get(
        Uri.parse('$baseUrl/get-products'),
        headers: _headers,
      );

      print('[ProductService] Response Status Code: ${response.statusCode}');
      print('[ProductService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Ürünler alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('[ProductService] Ürünler alınırken hata oluştu');
      print('[ProductService] $e');
      rethrow;
    }
  }

  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get-product/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Ürün alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('[ProductService] Ürün alınırken hata oluştu: $e');
      rethrow;
    }
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create-product'),
        headers: _headers,
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 201) {
        return ProductModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Ürün oluşturulamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('[ProductService] Ürün oluşturulurken hata oluştu: $e');
      rethrow;
    }
  }

  Future<ProductModel> updateProduct(int id, ProductModel product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update-product/$id'),
        headers: _headers,
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Ürün güncellenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('[ProductService] Ürün güncellenirken hata oluştu: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete-product/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Ürün silinemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('[ProductService] Ürün silinirken hata oluştu: $e');
      rethrow;
    }
  }
}
