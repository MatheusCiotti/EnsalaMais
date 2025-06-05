import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  // Inicializa o Supabase
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
    } catch (e) {
      throw 'Erro ao inicializar o Supabase: $e';
    }
  }


  // Cliente Supabase
  static SupabaseClient get client => Supabase.instance.client;

  // Usuário atual autenticado
  static User? get currentUser => client.auth.currentUser;

  // Stream de mudanças no estado de autenticação
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Cadastro de novo usuário
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final AuthResponse response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': fullName,
          'role': 'Aluno',
        },
      );

      if (response.user == null) {
        throw 'Erro ao criar usuário';
      }

      // Aguardar trigger criar registro na tabela users (se houver)
      await Future.delayed(const Duration(seconds: 1));

      return response;
    } on AuthException catch (e) {
      if (e.message.contains('Email already registered')) {
        throw 'Este e-mail já está registrado';
      } else if (e.message.contains('Password should be at least 6 characters')) {
        throw 'A senha deve ter pelo menos 6 caracteres';
      }
      throw e.message;
    } catch (e) {
      throw 'Erro ao criar conta: $e';
    }
  }

  // Login de usuário
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Tentando fazer login com email: $email');
      final AuthResponse response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        print('Erro: Usuário nulo após login');
        throw 'Erro ao fazer login';
      }

      print('Login bem-sucedido: ${response.user?.email}');
      return response;
    } on AuthException catch (e) {
      print('Erro de autenticação: ${e.message}');
      if (e.message.contains('Invalid login credentials')) {
        throw 'E-mail ou senha incorretos';
      }
      throw e.message;
    } catch (e) {
      print('Erro inesperado: $e');
      throw 'Erro ao fazer login: $e';
    }
  }

  // Logout do usuário
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw 'Erro ao fazer logout: $e';
    }
  }

  // Resetar senha via e-mail
  static Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw 'Erro ao enviar e-mail de recuperação: $e';
    }
  }

  // Atualizar perfil do usuário
  static Future<void> updateProfile({
    required String fullName,
    String? avatarUrl,
  }) async {
    try {
      await client.auth.updateUser(
        UserAttributes(
          data: {
            'name': fullName,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          },
        ),
      );

      final currentUser = client.auth.currentUser;
      if (currentUser != null) {
        await client
            .from('users')
            .update({
              'name': fullName,
            })
            .eq('id', currentUser.id);
      }
    } catch (e) {
      throw 'Erro ao atualizar perfil: $e';
    }
  }

  // *** NOVO: Buscar aulas da tabela "aulas" ***
 static Future<List<Map<String, dynamic>>> fetchAulas() async {
  try {
    final data = await client
        .from('aulas')
        .select()
        .order('horario', ascending: true) as List<dynamic>;

    return data.map((item) => Map<String, dynamic>.from(item)).toList();
  } catch (e) {
    throw 'Erro ao buscar aulas: $e';
  }
}
}