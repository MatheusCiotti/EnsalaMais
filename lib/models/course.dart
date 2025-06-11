// Este é o código completo e corrigido para o seu modelo de curso.

class Course {
  final int id;
  final String name;
  final int semester;
  final String period; // 'Matutino' ou 'Noturno'
  final String coordinator;
  final int duration; // Duração em semestres
  final String? description;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.name,
    required this.semester,
    required this.period,
    required this.coordinator,
    required this.duration,
    this.description,
    required this.createdAt,
  });

  // ===== FACTORY CORRIGIDO E SEGURO =====
  // Esta é a única parte que foi significativamente alterada.
  factory Course.fromJson(Map<String, dynamic> json) {
    // Função auxiliar para extrair o valor, seja de uma lista ou direto
    dynamic _extractValue(dynamic value) {
      return (value is List && value.isNotEmpty) ? value.first : value;
    }

    // Usamos a função auxiliar em todos os campos que podem ter o problema
    return Course(
      id: _extractValue(json['id']) as int,
      name: _extractValue(json['name']) as String,
      semester: _extractValue(json['semester']) as int,
      period: _extractValue(json['period']) as String,
      coordinator: _extractValue(json['coordinator']) as String,
      duration: _extractValue(json['duration']) as int,
      description: _extractValue(json['description']) as String?,
      createdAt: DateTime.tryParse(_extractValue(json['created_at'])?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'semester': semester,
      'period': period,
      'coordinator': coordinator,
      'duration': duration,
      'description': description,
    };
  }
}