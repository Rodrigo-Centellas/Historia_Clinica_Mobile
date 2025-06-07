import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'paciente_service.dart';
import '../models/paciente.dart';

class AuthService {
  final String baseUrl = dotenv.env['API_URL']!;

  Future<bool> loginPaciente(String email, String password) async {
    final token = await _loginAdmin(); // Login como admin
    if (token == null) return false;

    final paciente = await PacienteService().buscarPaciente(email, password, token);
    if (paciente == null) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setInt('paciente_id', paciente.id);
    await prefs.setString('paciente_nombre', paciente.nombre);
    await prefs.setString('paciente_email', paciente.email);
    await prefs.setString('paciente_telefono', paciente.telefonoContacto);

    return true;
  }

  Future<String?> _loginAdmin() async {
    final url = Uri.parse('$baseUrl/authenticate');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': 'admin',
        'password': 'admin',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id_token'];
    } else {
      print('❌ Error login admin: ${response.body}');
      return null;
    }
  }
}
