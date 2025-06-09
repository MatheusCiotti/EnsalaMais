import 'package:flutter/foundation.dart';

// CÓDIGO CORRIGIDO E SEGURO PARA 'user.dart'

class User {
  final String id;
  final String email;
  final String name;
  final String role;
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
    required this.email,
    required this.name,
    required this.role,
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
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? 'E-mail não informado',
      
      // Tenta buscar o nome de 'raw_user_meta_data', se não achar, busca de 'name', se não, usa um padrão.
      name: getNestedValue<String>(json, ['raw_user_meta_data', 'name']) 
            ?? json['name'] as String? 
            ?? 'Usuário sem nome',
      
      // Mesma lógica para o 'role'
      role: getNestedValue<String>(json, ['raw_user_meta_data', 'role'])
            ?? json['role'] as String?
            ?? 'Indefinido',

      // Tratamento seguro para a data de criação
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  // O método toJson não é necessário para esta tela, mas pode ser mantido se for usado em outro lugar
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
    };
  }
}