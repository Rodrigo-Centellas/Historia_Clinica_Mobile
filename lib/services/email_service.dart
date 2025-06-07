import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EmailService {
  final String? serviceId = dotenv.env['EMAILJS_SERVICE_ID'];
  final String? templateId = dotenv.env['EMAILJS_TEMPLATE_ID'];
  final String? userId = dotenv.env['EMAILJS_USER_ID'];

  Future<void> enviarConfirmacion({
    required String toEmail,
    required String toName,
    required String date,
    required String time,
    required String motivo,
    required String especialidad,
  }) async {
    if ([serviceId, templateId, userId].contains(null)) {
      debugPrint('❌ Error: Faltan variables en .env');
      return;
    }

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final payload = {
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': userId,
      'template_params': {
        'to_name': toName,
        'to_email': toEmail,
        'date': date,
        'time': time,
        'motivo': motivo,
        'especialidad': especialidad,
      },
    };

    try {
      debugPrint('📧 Enviando email a $toEmail...');
      debugPrint('📦 Payload: ${jsonEncode(payload)}');

      final response = await http.post(
        url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      debugPrint('📬 Código de respuesta: ${response.statusCode}');
      if (response.statusCode == 200) {
        debugPrint('✅ Email enviado con éxito');
      } else {
        debugPrint('❌ Error al enviar email: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Excepción al enviar email: $e');
    }
  }
}
