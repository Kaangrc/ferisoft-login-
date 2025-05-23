import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'product_service.dart';
import 'cart_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final String baseUrl = 'http://flutter.kodps.com/api';
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  void _setToken(String token) {
    _productService.setToken(token);
    _cartService.setToken(token);
  }

  Future<bool> register(UserModel user) async {
    try {
      print('[UserService] Register isteği gönderiliyor...');
      print('[UserService] URL: $baseUrl/register');
      print('[UserService] Request Body: ${user.toJson()}');

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _headers,
        body: json.encode(user.toJson()),
      );

      print('[UserService] Response Status Code: ${response.statusCode}');
      print('[UserService] Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['token'] != null) {
          _setToken(responseData['token']);
          return true;
        }
      } else if (response.statusCode == 422) {
        final responseData = json.decode(response.body);
        if (responseData['email'] != null &&
            responseData['email'].toString().contains('already been taken')) {
          // E-posta zaten kayıtlı, giriş yapılması gerekiyor
          return await login(user);
        }
      }
      return false;
    } catch (e) {
      print('[UserService] Register işlemi sırasında hata: $e');
      rethrow;
    }
  }

  Future<bool> login(UserModel user) async {
    try {
      print('[UserService] Login isteği gönderiliyor...');
      print('[UserService] URL: $baseUrl/login');
      print('[UserService] Request Body: ${user.toJson()}');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: json.encode(user.toJson()),
      );

      print('[UserService] Response Status Code: ${response.statusCode}');
      print('[UserService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          _setToken(data['token']);
          return true;
        }
        return false;
      } else {
        throw Exception('Giriş işlemi başarısız: ${response.statusCode}');
      }
    } catch (e) {
      print('[UserService] Login işlemi sırasında hata: $e');
      rethrow;
    }
  }
}
