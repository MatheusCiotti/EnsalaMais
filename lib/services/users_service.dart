import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class UsersService {
  static final _supabase = SupabaseService.client;

  // Verificar se o usuário atual é administrador
  static Future<bool> isAdmin() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;

      final response = await _supabase
          .from('users')
          .select('role')
          .eq('id', currentUser.id)
          .single();
      
      return response['role'] == 'Administração';
    } catch (e) {
      return false;
    }
  }

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
    if (!await isAdmin()) {
      throw Exception('Apenas administradores podem criar usuários');
    }

    try {
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
    } catch (e) {
      if (e.toString().contains('User already registered')) {
        throw Exception('Este e-mail já está cadastrado');
      }
      throw Exception('Erro ao criar usuário: ${e.toString()}');
    }
  }

  // Atualizar um usuário
  static Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String name,
    required String email,
    required String role,
  }) async {
    try {
      // Primeiro verificar se o usuário atual é administrador
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      final adminCheck = await _supabase
          .from('users')
          .select('role')
          .eq('id', currentUser.id)
          .single();

      if (adminCheck['role'] != 'Administração') {
        throw Exception('Apenas administradores podem atualizar usuários');
      }

      // Atualizar na tabela users
      final response = await _supabase
          .from('users')
          .update({
            'name': name,
            'email': email,
            'role': role,
          })
          .eq('id', userId)
          .select()
          .single();

      return response;
    } catch (e) {
      if (e.toString().contains('not found')) {
        throw Exception('Usuário não encontrado');
      } else if (e.toString().contains('duplicate key')) {
        throw Exception('Este e-mail já está em uso');
      } else if (e.toString().contains('permission denied')) {
        throw Exception('Você não tem permissão para realizar esta operação');
      }
      throw Exception('Erro ao atualizar usuário: ${e.toString()}');
    }
  }

  // Deletar um usuário
  static Future<void> deleteUser(String userId) async {
    if (!await isAdmin()) {
      throw Exception('Apenas administradores podem excluir usuários');
    }

    try {
      // Primeiro deletar o registro na tabela users
      await _supabase
          .from('users')
          .delete()
          .eq('id', userId);

      // Depois deletar o usuário no Auth
      await _supabase.auth.admin.deleteUser(userId);
    } catch (e) {
      throw Exception('Erro ao deletar usuário: ${e.toString()}');
    }
  }
} 