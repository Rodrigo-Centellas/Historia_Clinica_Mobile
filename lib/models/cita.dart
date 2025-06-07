class Cita {
  final int id;
  final String motivo;
  final String fechaHora;
  final String estado;
  final String pacienteNombre;
  final String pacienteEmail;
  final String medicoNombre;
  final String medicoEspecialidad;
  final String medicoCorreo;

  Cita({
    required this.id,
    required this.motivo,
    required this.fechaHora,
    required this.estado,
    required this.pacienteNombre,
    required this.pacienteEmail,
    required this.medicoNombre,
    required this.medicoEspecialidad,
    required this.medicoCorreo,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    final paciente = json['paciente'] ?? {};
    final medico = json['personalMedico'] ?? {};

    return Cita(
      id: json['id'],
      motivo: json['motivo'] ?? 'Sin motivo',
      fechaHora: "${json['fechaCita']} ${json['horaCita']}",
      estado: json['estado'] ?? 'Sin estado',
      pacienteNombre: paciente['nombre'] ?? 'Sin nombre',
      pacienteEmail: paciente['email'] ?? 'Sin email',
      medicoNombre: medico['nombre'] ?? 'Sin nombre',
      medicoEspecialidad: medico['especialidad'] ?? 'Sin especialidad',
      medicoCorreo: medico['correo'] ?? 'Sin correo',
    );
  }
}
