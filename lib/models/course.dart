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

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      semester: json['semester'],
      period: json['period'],
      coordinator: json['coordinator'],
      duration: json['duration'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
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