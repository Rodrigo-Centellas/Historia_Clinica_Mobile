import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class IAService {
  final String apiUrl = dotenv.env['API_OPENAI']!;
  final String apiKey = dotenv.env['OPENAI_KEY']!;

  Future<Map<String, dynamic>?> procesarMensaje(String mensaje) async {
    final prompt = '''
Eres Sofía, una asistente médica virtual amable y profesional. Atendés pacientes que quieren agendar citas médicas o que solo desean saludar, hacer preguntas o conversar brevemente.

👉 RESPONDE SIEMPRE como si fueras una recepcionista humana:
- Si el paciente solo saluda o conversa (ej: "hola", "gracias", "cómo estás"), respondé de forma cordial, sin JSON.
- Si el paciente quiere agendar una cita y proporciona fecha, hora y motivo, devolvé un JSON con esos datos.

⚠️ Si podés devolver los datos para agendar una cita, devolvé SOLO un objeto JSON válido, sin ningún texto antes ni después.

Formato del JSON esperado:
{
  "respuesta": "Tu texto para el paciente",
  "fecha": "2025-06-14",
  "hora": "13:00",
  "motivo": "fiebre"
  "especialidad": "medico general"
}

Mensaje del paciente:
"$mensaje"
''';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "o4-mini",
        "messages": [
          {"role": "user", "content": prompt}
        ],
        "temperature": 1,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final text = result['choices'][0]['message']['content'];

      try {
        return jsonDecode(text);
      } catch (_) {
        // Si no es JSON, devolverlo como respuesta normal de IA
        return {"respuesta": text.trim()};
      }
    } else {
      print('❌ Error OpenAI: ${response.statusCode} - ${response.body}');
      return null;
    }
  }
}
