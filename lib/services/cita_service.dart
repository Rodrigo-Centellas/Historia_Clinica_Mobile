import 'dart:convert';
import 'package:cita_medica/models/cita.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class CitaService {
  final String baseUrl = dotenv.env['API_URL']!;

  Future<List<Cita>> getCitasByPaciente(int pacienteId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final url = Uri.parse('$baseUrl/cita-medicas');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      debugPrint('👤 ID paciente logueado: $pacienteId');
      debugPrint('📦 Total de citas recibidas: ${data.length}');

      final citasFiltradas = data.where((c) {
        final paciente = c['paciente'];
        return paciente != null && paciente['id'] == pacienteId;
      }).toList();

      debugPrint('✅ Citas del paciente: ${citasFiltradas.length}');

      return citasFiltradas.map((json) => Cita.fromJson(json)).toList();
    } else {
      debugPrint('❌ Error al cargar citas: ${response.body}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCitasDelMedico(int medicoId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final url = Uri.parse('$baseUrl/cita-medicas');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List citas = jsonDecode(response.body);
      return citas.where((c) => c['personalMedico']?['id'] == medicoId).toList().cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  // Future<bool> verificarDisponibilidadMedico(int medicoId, String fecha, String hora) async {
  //   final citas = await getCitasDelMedico(medicoId);
  //   return !citas.any((c) => c['fechaCita'] == fecha && c['horaCita'] == hora);
  // }

  Future<bool> crearCita(int pacienteId, String fecha, String hora, String motivo, int medicoId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final url = Uri.parse('$baseUrl/cita-medicas');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "fechaCita": fecha,
        "horaCita": hora,
        "motivo": motivo,
        "estado": "Pendiente",
        "paciente": {"id": pacienteId},
        "personalMedico": {"id": medicoId}
      }),
    );

    debugPrint('📤 Crear cita response: ${response.statusCode}');
    return response.statusCode == 201;
  }

  Future<bool> crearCitaConDoctor(
  int pacienteId,
  String fecha,
  String hora,
  String motivo,
  int idDoctor,
) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  final url = Uri.parse('$baseUrl/cita-medicas');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "fechaCita": fecha,
      "horaCita": hora,
      "motivo": motivo,
      "estado": "Pendiente",
      "paciente": {"id": pacienteId},
      "personalMedico": {"id": idDoctor}
    }),
  );

  debugPrint('📤 Crear cita con doctor response: ${response.statusCode}');
  return response.statusCode == 201;
}

Future<bool> verificarDisponibilidadMedico(
  int medicoId,
  String fecha,
  String hora,
) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  final url = Uri.parse('$baseUrl/cita-medicas');
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode != 200) return false;

  final List data = jsonDecode(response.body);
  return !data.any((cita) =>
      cita['personalMedico']?['id'] == medicoId &&
      cita['fechaCita'] == fecha &&
      cita['horaCita'] == hora);
}


  
  
}
