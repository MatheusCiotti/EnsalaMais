class Class {
  final String id;
  final String name;
  
  // CAMPOS QUE PODEM SER NULOS
  final String? schedule; // Tornamos o horário anulável para máxima segurança
  final String? observation;
  final String? professorId;
  final String? professorName;
  final int? roomId;
  final String? roomName;
  final String? courseName; // NOVO

  Class({
    required this.id,
    required this.name,
    this.schedule,
    this.observation,
    this.professorId,
    this.professorName,
    this.roomId,
    this.roomName,
    this.courseName,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    // Função auxiliar para extrair o valor, seja de uma lista ou direto
    dynamic _extractValue(dynamic value) {
      return (value is List && value.isNotEmpty) ? value.first : value;
    }
    
    // Extrai o nome do curso da estrutura aninhada que vamos buscar
    String? courseName;
    if (json['course_classes'] != null && (json['course_classes'] as List).isNotEmpty) {
      final courseLink = json['course_classes'][0];
      if (courseLink['courses'] != null) {
        courseName = courseLink['courses']['name'];
      }
    }

    return Class(
      id: _extractValue(json['id']) as String,
      name: _extractValue(json['name']) as String,
      schedule: _extractValue(json['schedule']) as String?,
      observation: _extractValue(json['observation']) as String?,
      professorId: _extractValue(json['professor_id']) as String?,
      roomId: _extractValue(json['room_id']) as int?,
      professorName: json['professor']?['name'] as String?,
      roomName: json['room']?['nome'] as String?,
      courseName: courseName,
    );
  }
}