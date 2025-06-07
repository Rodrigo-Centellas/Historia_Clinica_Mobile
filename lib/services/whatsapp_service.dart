import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WhatsAppService {
  final String? sid = dotenv.env['TWILIO_SID'];
  final String? token = dotenv.env['TWILIO_AUTH_TOKEN'];
  final String? from = dotenv.env['TWILIO_FROM'];
  final String? templateId = dotenv.env['TWILIO_TEMPLATE_ID'];

  Future<void> enviarConfirmacion({
    required String to,
    required String paciente,
    required String fecha,
    required String hora,
    required String motivo,
    required String especialista,
  }) async {
    final url = Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$sid/Messages.json');

    final body = {
      'To': 'whatsapp:$to',
      'From': from,
      'ContentSid': templateId,
      'ContentVariables': jsonEncode({
        '1': paciente,
        '2': fecha,
        '3': hora,
        '4': motivo,
        '5': especialista,
      }),
    };

    debugPrint("📤 Enviando WhatsApp con plantilla...");
    debugPrint("📨 Para: $to");
    debugPrint("📦 Variables: ${body['ContentVariables']}");

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$sid:$token'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    debugPrint("📬 Código de respuesta: ${response.statusCode}");
    if (response.statusCode != 201 && response.statusCode != 200) {
      debugPrint("❌ Error al enviar WhatsApp: ${response.body}");
    } else {
      debugPrint("✅ Mensaje enviado correctamente");
    }
  }
}
