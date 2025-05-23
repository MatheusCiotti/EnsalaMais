import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
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

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final AuthResponse response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user == null) {
        throw 'Erro ao criar usuário';
      }

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

  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw 'Erro ao fazer logout: $e';
    }
  }

  static Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw 'Erro ao enviar e-mail de recuperação: $e';
    }
  }

  static Future<void> updateProfile({
    required String fullName,
    String? avatarUrl,
  }) async {
    try {
      await client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullName,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          },
        ),
      );
    } catch (e) {
      throw 'Erro ao atualizar perfil: $e';
    }
  }
} 