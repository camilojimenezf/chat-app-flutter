import 'dart:convert';

import 'package:chat/global/environment.dart';
import 'package:chat/models/login_response.dart';
import 'package:chat/models/usuarios.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService with ChangeNotifier {
  late Usuario usuario;
  bool _autenticando = false;
  final _storage = FlutterSecureStorage();

  bool get autenticando => this._autenticando;

  set autenticando(bool valor) {
    this._autenticando = valor;
    notifyListeners();
  }

  static Future<String?> getToken() async {
    final _storage = FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token;
  }

  static Future<void> deleteToken() async {
    final _storage = FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }

  Future<bool> login(String email, String password) async {
    this.autenticando = true;

    final data = {
      'email': email,
      'password': password,
    };

    final uri = Uri.parse('${Environment.apiUrl}/login');
    final res = await http.post(
      uri,
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );

    this.autenticando = false;

    if (res.statusCode == 200) {
      final loginResponse = loginResponseFromJson(res.body);
      this.usuario = loginResponse.usuario;
      await this._guardarToken(loginResponse.token);

      return true;
    }

    return false;
  }

  Future register(String nombre, String email, String password) async {
    this.autenticando = true;

    final data = {
      'nombre': nombre,
      'email': email,
      'password': password,
    };

    final uri = Uri.parse('${Environment.apiUrl}/login/new');
    final res = await http.post(
      uri,
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );

    this.autenticando = false;

    if (res.statusCode == 200) {
      final loginResponse = loginResponseFromJson(res.body);
      this.usuario = loginResponse.usuario;
      await this._guardarToken(loginResponse.token);

      return true;
    }

    final respBody = jsonDecode(res.body);
    return respBody['msg'];
  }

  Future<bool> isLoggedIn() async {
    final token = await this._storage.read(key: 'token');

    final uri = Uri.parse('${Environment.apiUrl}/login/renew');

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-token': token.toString(),
      },
    );

    this.autenticando = false;

    if (res.statusCode == 200) {
      final loginResponse = loginResponseFromJson(res.body);
      this.usuario = loginResponse.usuario;
      await this._guardarToken(loginResponse.token);

      return true;
    }

    this.logout();
    return false;
  }

  Future _guardarToken(String token) async {
    return await _storage.write(key: 'token', value: token);
  }

  Future logout() async {
    await _storage.delete(key: 'token');
  }
}
