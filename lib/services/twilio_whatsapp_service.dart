import 'dart:convert';
import 'package:http/http.dart' as http;

class TwilioWhatsAppService {
  final String accountSid = 'ACbfc201cdc3c5292e79e105e2e005f903';
  final String authToken = '74fc0bb30d34dfc8ec3155a267e2cd33';
  final String fromNumber = 'whatsapp:+14155238886'; // Twilio Sandbox
  final String contentSid = 'HX3616cb43292c8e2f3e2c03ea1e826e18'; // Plantilla aprobada

  Future<bool> enviarConfirmacion({
    required String telefono,
    required String fecha,
    required String hora,
  }) async {
    final url = Uri.parse(
      'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json',
    );

    final body = {
      'To': 'whatsapp:$telefono',
      'From': fromNumber,
      'ContentSid': contentSid,
      'ContentVariables': jsonEncode({
        '1': fecha,
        '2': hora,
      }),
    };

    final auth = base64Encode(utf8.encode('$accountSid:$authToken'));

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic $auth',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      print('✅ Mensaje de WhatsApp enviado');
      return true;
    } else {
      print('❌ Error al enviar mensaje: ${response.body}');
      return false;
    }
  }
}
