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
  factory Course.fromJson(Map<String, dynamic> json) {
    // Função auxiliar para extrair o valor, seja de uma lista ou direto
    dynamic _extractValue(dynamic value) {
      return (value is List && value.isNotEmpty) ? value.first : value;
    }

    // Tratamento seguro de valores nulos
    return Course(
      id: _extractValue(json['id']) as int? ?? 0,
      name: _extractValue(json['name']) as String? ?? 'Curso sem nome',
      semester: _extractValue(json['semester']) as int? ?? 1,
      period: _extractValue(json['period']) as String? ?? 'Não definido',
      coordinator: _extractValue(json['coordinator']) as String? ?? 'Não definido',
      duration: _extractValue(json['duration']) as int? ?? 1,
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