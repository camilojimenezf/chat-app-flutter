import 'package:chat/models/usuarios.dart';
import 'package:chat/global/environment.dart';
import 'package:chat/models/usuarios_response.dart';
import 'package:chat/services/auth_service.dart';

import 'package:http/http.dart' as http;

class UsuariosService {
  Future<List<Usuario>> getUsuarios() async {
    try {
      final uri = Uri.parse('${Environment.apiUrl}/usuarios');

      final res = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'x-token': await AuthService.getToken() ?? ''
      });

      final usuariosResponse = usuariosResponseFromJson(res.body);

      return usuariosResponse.usuarios;
    } catch (e) {
      return [];
    }
  }
}
