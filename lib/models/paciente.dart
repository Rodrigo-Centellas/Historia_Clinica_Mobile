class Paciente {
  final int id;
  final String nombre;
  final String email;
  final String password;

  Paciente({
    required this.id,
    required this.nombre,
    required this.email,
    required this.password,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      password: json['password'] ?? '',
    );
  }
}
