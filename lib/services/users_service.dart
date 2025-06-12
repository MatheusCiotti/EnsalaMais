import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user; // Importe o modelo User com o apelido app_user
import '../services/supabase_service.dart';

class UsersService {
  static final _supabase = SupabaseService.client;

  // Função para verificar se o usuário atual é administrador (mantida como estava)
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

  // Função GETUSERS ATUALIZADA para aceitar um filtro de role
  static Future<List<app_user.User>> getUsers({String? role}) async {
    try {
      var query = _supabase.from('users').select();

      // Se um 'role' for fornecido (e não for 'Todos'), adiciona o filtro
      if (role != null && role != 'Todos') {
        query = query.eq('role', role);
      }

      final response = await query.order('name', ascending: true);
      
      return response.map((json) => app_user.User.fromJson(json)).toList();

    } catch (e) {
      throw Exception('Erro ao carregar usuários: ${e.toString()}');
    }
  }

  // Função para criar um novo usuário (mantida como estava)
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

  // Função UPDATEUSER revisada para consistência
  static Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String name,
    required String email,
    required String role,
  }) async {
    try {
      final response = await _supabase
          .from('users')
          .update({'name': name, 'email': email, 'role': role})
          .eq('id', userId)
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('Erro ao atualizar usuário: ${e.toString()}');
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      // Chama a Edge Function segura no servidor para fazer a exclusão
      final response = await _supabase.functions.invoke(
        'delete-user', // Nome exato da sua Edge Function
        body: {'userId': userId}, // Envia o ID do usuário a ser deletado
      );

      // A Edge Function nos dirá se houve um erro do lado dela
      if (response.status != 200) {
        final Map<String, dynamic> responseData = response.data;
        // Lança uma exceção com a mensagem de erro vinda da função
        throw Exception(responseData['error'] ?? 'Erro desconhecido ao executar a função no servidor.');
      }
      
      // Se chegou aqui, a função foi executada com sucesso no servidor.
      print('A função para deletar o usuário foi chamada com sucesso.');

    } catch (e) {
      // Propaga o erro para a UI (sua tela) poder mostrar o SnackBar
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}