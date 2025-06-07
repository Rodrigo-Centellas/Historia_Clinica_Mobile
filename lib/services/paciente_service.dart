import 'dart:convert';
import 'package:cita_medica/models/paciente.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PacienteService {
  final String baseUrl = dotenv.env['API_URL']!;

  Future<Paciente?> buscarPaciente(String email, String password, String token) async {
    final url = Uri.parse('$baseUrl/pacientes');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      print('🔍 Buscando paciente con email: $email');

      final match = data.firstWhere(
        (p) => p['email'] == email,
        orElse: () => null,
      );

      if (match == null) return null;

      // Comparación manual del password
      if (match['password'] != password) {
        print('❌ Contraseña incorrecta');
        return null;
      }

      return Paciente.fromJson(match);
    } else {
      print('❌ Error buscando paciente: ${response.body}');
      return null;
    }
  }
}
