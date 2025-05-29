class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'Professor', 'Aluno', 'Área Técnica', 'Administração'
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Tenta obter o nome e role primeiro dos metadados, depois diretamente
    final name = json['raw_user_meta_data']?['name'] ?? json['name'] ?? '';
    final role = json['raw_user_meta_data']?['role'] ?? json['role'] ?? 'Aluno';
    final email = json['email'] ?? '';
    
    return User(
      id: json['id'] ?? '',
      name: name,
      email: email,
      role: role,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
    };
  }

  static List<String> get roles => [
    'Professor',
    'Aluno',
    'Área Técnica',
    'Administração',
  ];
} 