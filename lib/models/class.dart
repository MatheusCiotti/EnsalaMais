class Class {
  final String id;
  final String? name;
  
  // CAMPOS QUE PODEM SER NULOS
  final String? schedule; // Tornamos o horário anulável para máxima segurança
  final String? observation;
  final String? professorId;
  final String? professorName;
  final int? roomId;
  final String? roomName;
  final String? courseName; // Este campo pode não ser mais necessário, mas vamos manter
  final int? courseSemester;

  Class({
    required this.id,
    this.name,
    this.schedule,
    this.observation,
    this.professorId,
    this.professorName,
    this.roomId,
    this.roomName,
    this.courseName,
    this.courseSemester,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'] as String,
      name: json['name'] as String?,
      schedule: json['schedule'] as String?,
      observation: json['observation'] as String?,
      professorId: json['professor_id'] as String?,
      professorName: json['professor']?['name'] as String?,
      roomId: json['room_id'] as int?,
      roomName: json['room']?['nome'] as String?,
      courseName: json['course_name'] as String?,
      courseSemester: json['courseSemester'] as int?,
    );
  }
}