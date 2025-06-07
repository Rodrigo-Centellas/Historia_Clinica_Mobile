import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cita_medica/services/ia_service.dart';
import 'package:cita_medica/services/cita_service.dart';
import 'package:cita_medica/services/whatsapp_service.dart';
import 'package:cita_medica/services/email_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _mensajes = [];
  final TextEditingController _controller = TextEditingController();
  final IAService _iaService = IAService();
  bool _isLoading = false;

  final Map<String, int> _especialidadToId = {
    'medico general': 1,
    'dermatologo': 2,
  };

  void _enviarMensaje() async {
    final mensaje = _controller.text.trim();
    if (mensaje.isEmpty) return;

    setState(() {
      _mensajes.add({'role': 'user', 'text': mensaje});
      _isLoading = true;
      _controller.clear();
    });

    final respuesta = await _iaService.procesarMensaje(mensaje);

    if (respuesta != null &&
        respuesta.containsKey('fecha') &&
        respuesta.containsKey('hora') &&
        respuesta.containsKey('motivo') &&
        respuesta.containsKey('especialidad')) {
      final prefs = await SharedPreferences.getInstance();
      final pacienteId = prefs.getInt('paciente_id') ?? 0;
      final pacienteNombre = prefs.getString('paciente_nombre') ?? '';
      final telefono =
          prefs.getString('paciente_telefono') ?? ''; // debe guardarse en login

      final fecha = respuesta['fecha'];
      final hora = respuesta['hora'];
      final motivo = respuesta['motivo'];
      final especialidad = respuesta['especialidad'].toString().toLowerCase();

      final idMedico = _especialidadToId[especialidad];

      if (idMedico == null) {
        setState(() {
          _mensajes.add({
            'role': 'assistant',
            'text':
                '❌ No encontré un doctor para la especialidad "$especialidad".',
          });
          _isLoading = false;
        });
        return;
      }

      final disponible = await CitaService().verificarDisponibilidadMedico(
        idMedico,
        fecha,
        hora,
      );

      if (!disponible) {
        setState(() {
          _mensajes.add({
            'role': 'assistant',
            'text':
                '⏰ El doctor de $especialidad ya tiene una cita a esa hora. ¿Deseas otro horario?',
          });
          _isLoading = false;
        });
        return;
      }

      final creada = await CitaService().crearCitaConDoctor(
        pacienteId,
        fecha,
        hora,
        motivo,
        idMedico,
      );

      if (creada) {
        try {
          if (telefono.isNotEmpty) {
            await WhatsAppService().enviarConfirmacion(
              to: '591$telefono',
              paciente: pacienteNombre,
              fecha: fecha,
              hora: hora,
              motivo: motivo,
              especialista: especialidad,
            );
          }

          final email = prefs.getString('paciente_email') ?? '';
          if (email.isNotEmpty) {
            await EmailService().enviarConfirmacion(
              toEmail: email,
              toName: pacienteNombre,
              date: fecha,
              time: hora,
              motivo: motivo,
              especialidad: especialidad,
            );
          }
        } catch (e) {
          debugPrint('❌ Error al enviar confirmaciones: $e');
        }

        setState(() {
          _mensajes.add({
            'role': 'assistant',
            'text':
                '✅ Tu cita ha sido registrada para el $fecha a las $hora con el doctor de $especialidad.\nMotivo: $motivo',
          });
        });
      } else {
        setState(() {
          _mensajes.add({
            'role': 'assistant',
            'text': '❌ Hubo un error al registrar la cita. Intenta nuevamente.',
          });
        });
      }

      setState(() => _isLoading = false);
    } else {
      final texto =
          respuesta?['respuesta'] ??
          '❌ No entendí tu mensaje. ¿Podés ser más claro?';
      setState(() {
        _mensajes.add({'role': 'assistant', 'text': texto});
        _isLoading = false;
      });
    }
  }

  Widget _buildMensaje(String role, String text) {
    final isUser = role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agente Médico IA")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final mensaje = _mensajes[index];
                return _buildMensaje(mensaje['role']!, mensaje['text']!);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                    ),
                    onSubmitted: (_) => _enviarMensaje(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _enviarMensaje,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
