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
    // Função auxiliar para extrair o valor, seja ele um item de lista ou um valor direto.
    // Isso resolve o problema dos colchetes [].
    dynamic _extractValue(dynamic value) {
      return (value is List && value.isNotEmpty) ? value.first : value;
    }

    return Course(
      // Adicionamos 'as int', 'as String', etc., para garantir a segurança dos tipos.
      id: _extractValue(json['id']) as int,
      name: _extractValue(json['name']) as String,
      semester: _extractValue(json['semester']) as int,
      period: _extractValue(json['period']) as String,
      coordinator: _extractValue(json['coordinator']) as String,
      duration: _extractValue(json['duration']) as int,
      
      // O campo description já é anulável, então o tratamento é mais simples.
      description: json['description'] as String?,
      
      // Usamos tryParse para evitar erros se a data vier em formato incorreto ou nula.
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
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