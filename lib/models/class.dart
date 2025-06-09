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

  Class({
    required this.id,
    required this.name,
    this.schedule,
    this.observation,
    this.professorId,
    this.professorName,
    this.roomId,
    this.roomName,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'] as String,
      name: json['name'] as String,
      
      // CONVERSÃO SEGURA PARA TIPOS ANULÁVEIS
      schedule: json['schedule'] as String?,
      observation: json['observation'] as String?,
      professorId: json['professor_id'] as String?,
      professorName: json['professor_name'] as String?,
      roomId: json['room_id'] as int?,
      roomName: json['room_name'] as String?,
    );
  }
}