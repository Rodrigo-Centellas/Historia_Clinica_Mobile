import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:cita_medica/models/cita.dart';
import 'package:cita_medica/services/cita_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Cita>> _citasFuture;
  int _pacienteId = 0;
  String _pacienteNombre = '';
  String _pacienteEmail = '';

  @override
  void initState() {
    super.initState();
    _citasFuture = _loadCitasDelPaciente();
  }

  Future<List<Cita>> _loadCitasDelPaciente() async {
    final prefs = await SharedPreferences.getInstance();
    _pacienteId = prefs.getInt('paciente_id') ?? 0;
    _pacienteNombre = prefs.getString('paciente_nombre') ?? '';
    _pacienteEmail = prefs.getString('paciente_email') ?? 'no disponible';

    debugPrint('📲 Paciente ID: $_pacienteId');
    debugPrint('📧 Paciente Email: $_pacienteEmail');

    return await CitaService().getCitasByPaciente(_pacienteId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio del Paciente')),
      body: FutureBuilder<List<Cita>>(
        future: _citasFuture,
        builder: (context, snapshot) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🧑 Paciente: $_pacienteNombre", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text("📧 Email: $_pacienteEmail"),
                    Text("🆔 ID: $_pacienteId"),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/chat');
                  },
                  child: const Text('Agendar con Agente IA'),
                ),
              ),
              const Divider(),
              Expanded(child: _buildCitaList(snapshot)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCitaList(AsyncSnapshot<List<Cita>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return const Center(child: Text('❌ Error al cargar citas'));
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(child: Text('📭 No hay citas registradas.'));
    }

    final citas = snapshot.data!;

    return ListView.builder(
      itemCount: citas.length,
      itemBuilder: (context, index) {
        final cita = citas[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('${cita.motivo} - ${cita.estado}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🕓 ${cita.fechaHora}'),
                Text('👤 Paciente: ${cita.pacienteNombre}'),
                Text('📧 Email: ${cita.pacienteEmail}'),
                const Divider(),
                Text('👨‍⚕️ Médico: ${cita.medicoNombre}'),
                Text('📚 Especialidad: ${cita.medicoEspecialidad}'),
                Text('✉️ Correo: ${cita.medicoCorreo}'),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}
