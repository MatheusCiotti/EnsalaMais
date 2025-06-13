import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../services/supabase_service.dart';
import '../models/user.dart';

class UserService {
  static final _supabase = SupabaseService.client;

  // Buscar dados completos do usuário atual
  static Future<User?> getCurrentUserData() async {
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) return null;

      final response = await _supabase
          .from('users')
          .select('*')
          .eq('id', currentUser.id)
          .maybeSingle();

      if (response == null) return null;

      return User.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao carregar dados do usuário: ${e.toString()}');
    }
  }

  // Atualizar perfil do usuário
  static Future<void> updateUserProfile({
    required String name,
    int? courseId,
  }) async {
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não está logado');
      }

      final updateData = <String, dynamic>{
        'name': name,
      };

      if (courseId != null) {
        updateData['course_id'] = courseId;
      }

      await _supabase
          .from('users')
          .update(updateData)
          .eq('id', currentUser.id);

    } catch (e) {
      throw Exception('Erro ao atualizar perfil: ${e.toString()}');
    }
  }

  // Atualizar senha do usuário
  static Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Erro ao atualizar senha: ${e.toString()}');
    }
  }

  // Buscar aulas do dia filtradas por curso do usuário
  static Future<List<Map<String, dynamic>>> getTodayClassesByCourse(int courseId) async {
    try {
      final today = DateTime.now();
      final dayOfWeek = _getDayOfWeekInPortuguese(today.weekday);

      print('Buscando aulas para o dia: $dayOfWeek, curso: $courseId');

      final response = await _supabase
          .from('ensalamentos')
          .select('''
            *,
            room:rooms(*),
            class:classes!inner(
              *,
              course_classes!inner(
                courses!inner(id, name, semester)
              )
            )
          ''')
          .eq('day_of_week', dayOfWeek)
          .eq('class.course_classes.courses.id', courseId)
          .order('time_slot');

      print('Resposta da consulta de ensalamentos: $response');

      // Buscar professores separadamente para todas as aulas
      final List<Map<String, dynamic>> enrichedResponse = [];
      for (final item in response) {
        final classData = item['class'];
        final professorId = classData?['professor_id'];
        
        String? professorName;
        if (professorId != null) {
          try {
            print('Buscando professor com ID: $professorId');
            final professorResponse = await _supabase
                .from('users')
                .select('name')
                .eq('id', professorId)
                .maybeSingle();
            
            professorName = professorResponse?['name'];
            print('Professor encontrado para ID $professorId: $professorName');
          } catch (e) {
            print('Erro ao buscar professor $professorId: $e');
          }
        } else {
          print('Professor ID é null para a aula: ${classData?['name']}');
        }
        
        // Adicionar o nome do professor aos dados da aula
        final enrichedItem = Map<String, dynamic>.from(item);
        if (enrichedItem['class'] != null) {
          enrichedItem['class'] = Map<String, dynamic>.from(enrichedItem['class']);
          enrichedItem['class']['professor'] = {'name': professorName ?? 'Professor não encontrado'};
        }
        
        enrichedResponse.add(enrichedItem);
      }
      
      print('Resposta enriquecida com professores: $enrichedResponse');
      return enrichedResponse;
    } catch (e) {
      throw Exception('Erro ao carregar aulas do dia: ${e.toString()}');
    }
  }

  // Buscar aulas do dia de um professor específico
  static Future<List<Map<String, dynamic>>> getTodayClassesByProfessor(String professorId) async {
    try {
      final today = DateTime.now();
      final dayOfWeek = _getDayOfWeekInPortuguese(today.weekday);

      // Primeira tentativa: buscar com join
      try {
        final response = await _supabase
            .from('ensalamentos')
            .select('''
              *,
              room:rooms(*),
              class:classes!inner(
                *,
                professor:users!professor_id(name),
                course_classes(
                  courses(id, name, semester)
                )
              )
            ''')
            .eq('day_of_week', dayOfWeek)
            .eq('class.professor_id', professorId)
            .order('time_slot');

        return List<Map<String, dynamic>>.from(response);
      } catch (joinError) {
        // Se o join falhar, fazer consulta separada
        print('Join falhou para professor, tentando consulta separada: $joinError');
        
        final response = await _supabase
            .from('ensalamentos')
            .select('''
              *,
              room:rooms(*),
              class:classes!inner(
                *,
                course_classes(
                  courses(id, name, semester)
                )
              )
            ''')
            .eq('day_of_week', dayOfWeek)
            .eq('class.professor_id', professorId)
            .order('time_slot');

        // Buscar nome do professor separadamente
        String? professorName;
        try {
          final professorResponse = await _supabase
              .from('users')
              .select('name')
              .eq('id', professorId)
              .maybeSingle();
          
          professorName = professorResponse?['name'];
        } catch (e) {
          print('Erro ao buscar professor $professorId: $e');
        }
        
        // Adicionar o nome do professor aos dados das aulas
        final List<Map<String, dynamic>> enrichedResponse = [];
        for (final item in response) {
          final enrichedItem = Map<String, dynamic>.from(item);
          if (enrichedItem['class'] != null) {
            enrichedItem['class'] = Map<String, dynamic>.from(enrichedItem['class']);
            enrichedItem['class']['professor'] = {'name': professorName};
          }
          
          enrichedResponse.add(enrichedItem);
        }
        
        return enrichedResponse;
      }
    } catch (e) {
      throw Exception('Erro ao carregar aulas do professor: ${e.toString()}');
    }
  }

  // Converter número do dia da semana para português
  static String _getDayOfWeekInPortuguese(int weekday) {
    switch (weekday) {
      case 1: return 'Segunda-feira';
      case 2: return 'Terça-feira';
      case 3: return 'Quarta-feira';
      case 4: return 'Quinta-feira';
      case 5: return 'Sexta-feira';
      case 6: return 'Sábado';
      case 7: return 'Domingo';
      default: return 'Segunda-feira';
    }
  }
} 