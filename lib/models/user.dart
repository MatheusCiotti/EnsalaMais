import 'package:flutter/foundation.dart';

// CÓDIGO CORRIGIDO E SEGURO PARA 'user.dart'

class User {
  final String id;
  final String? name;
  final String? email;
  final String? role;
  final String? funcao;
  final int? courseId;
  final DateTime createdAt;

  // Lista estática de papéis para ser usada em dropdowns
  static List<String> get roles => [
    'Administração',
    'Professor',
    'Aluno',
    'Área Técnica',
  ];

  User({
    required this.id,
    this.name,
    this.email,
    this.role,
    this.funcao,
    this.courseId,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Função para extrair dados aninhados de forma segura
    T? getNestedValue<T>(Map<String, dynamic> data, List<String> keys) {
      dynamic value = data;
      for (var key in keys) {
        if (value is Map<String, dynamic> && value.containsKey(key)) {
          value = value[key];
        } else {
          return null;
        }
      }
      return value is T ? value : null;
    }

    return User(
      // Tratamento seguro para cada campo
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      funcao: json['funcao'] as String?,
      courseId: json['course_id'] as int?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  // O método toJson não é necessário para esta tela, mas pode ser mantido se for usado em outro lugar
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'funcao': funcao,
      'course_id': courseId,
    };
  }
}