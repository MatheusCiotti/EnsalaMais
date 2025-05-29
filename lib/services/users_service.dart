import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class UsersService {
  static final _supabase = SupabaseService.client;

  // Buscar todos os usuários
  static Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await _supabase
        .from('users')
        .select('''
          id,
          name,
          email,
          role,
          created_at
        ''')
        .order('name');
    
    // Converter a resposta para o formato esperado
    return response.map<Map<String, dynamic>>((user) {
      return {
        'id': user['id'],
        'name': user['name'],
        'email': user['email'],
        'role': user['role'],
        'created_at': user['created_at'],
        'raw_user_meta_data': {
          'name': user['name'],
          'role': user['role'],
        },
      };
    }).toList();
  }

  // Criar um novo usuário
  static Future<AuthResponse> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final AuthResponse response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'role': role,
      },
    );

    if (response.user == null) {
      throw Exception('Erro ao criar usuário');
    }

    return response;
  }

  // Atualizar um usuário
  static Future<Map<String, dynamic>> updateUser({
    required String id,
    required String name,
    required String role,
  }) async {
    await _supabase.auth.admin.updateUserById(
      id,
      attributes: AdminUserAttributes(
        userMetadata: {
          'name': name,
          'role': role,
        },
      ),
    );

    final response = await _supabase
        .from('users')
        .update({
          'name': name,
          'role': role,
        })
        .eq('id', id)
        .select()
        .single();
    
    return response;
  }

  // Deletar um usuário
  static Future<void> deleteUser(String id) async {
    await _supabase.auth.admin.deleteUser(id);
  }
} 