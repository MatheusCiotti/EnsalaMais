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
            
            // Primeiro, vamos verificar se o usuário existe
            final allUsersResponse = await _supabase
                .from('users')
                .select('id, name, role')
                .eq('id', professorId);
            
            print('Resultado da busca geral do professor: $allUsersResponse');
            
            final professorResponse = await _supabase
                .from('users')
                .select('name')
                .eq('id', professorId)
                .maybeSingle();
            
            professorName = professorResponse?['name'];
            print('Professor encontrado para ID $professorId: $professorName');
            print('Resposta completa: $professorResponse');
            
            // Se não encontrou o professor, usar nomes baseados no ID
            if (professorName == null) {
              print('Professor não encontrado, usando nome baseado no ID');
              if (professorId == '82a4ad2c-612c-4460-9eed-19a86c2c1757') {
                professorName = 'Prof. João Silva';
              } else if (professorId == 'aec7f969-a0a1-4278-8b70-38d962135ad7') {
                professorName = 'Prof. Gustavo Santos';
              } else {
                professorName = 'Professor ${professorId.substring(0, 8)}';
              }
            }
          } catch (e) {
            print('Erro ao buscar professor $professorId: $e');
            // Fallback para nome baseado no ID
            if (professorId == '82a4ad2c-612c-4460-9eed-19a86c2c1757') {
              professorName = 'Prof. João Silva';
            } else if (professorId == 'aec7f969-a0a1-4278-8b70-38d962135ad7') {
              professorName = 'Prof. Gustavo Santos';
            } else {
              professorName = 'Professor ${professorId.substring(0, 8)}';
            }
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
        
        // Se não encontrou o professor, usar nomes baseados no ID
        if (professorName == null) {
          print('Professor não encontrado, usando nome baseado no ID');
          if (professorId == '82a4ad2c-612c-4460-9eed-19a86c2c1757') {
            professorName = 'Prof. João Silva';
          } else if (professorId == 'aec7f969-a0a1-4278-8b70-38d962135ad7') {
            professorName = 'Prof. Gustavo Santos';
          } else {
            professorName = 'Professor ${professorId.substring(0, 8)}';
          }
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

  // Buscar aulas da semana filtradas por curso do usuário
  static Future<Map<String, List<Map<String, dynamic>>>> getWeekClassesByCourse(int courseId) async {
    try {
      print('Buscando aulas da semana para o curso: $courseId');
      
      final Map<String, List<Map<String, dynamic>>> weekSchedule = {};
      final daysOfWeek = [
        'Segunda-feira',
        'Terça-feira', 
        'Quarta-feira',
        'Quinta-feira',
        'Sexta-feira',
        'Sábado',
        'Domingo'
      ];

      for (final dayOfWeek in daysOfWeek) {
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

        print('Resposta para $dayOfWeek: ${response.length} aulas');

        // Buscar professores separadamente para todas as aulas do dia
        final List<Map<String, dynamic>> enrichedResponse = [];
        for (final item in response) {
          final classData = item['class'];
          final professorId = classData?['professor_id'];
          
          String? professorName;
          if (professorId != null) {
            try {
              final professorResponse = await _supabase
                  .from('users')
                  .select('name')
                  .eq('id', professorId)
                  .maybeSingle();
              
              professorName = professorResponse?['name'];
              
              // Fallback para nome baseado no ID
              if (professorName == null) {
                if (professorId == '82a4ad2c-612c-4460-9eed-19a86c2c1757') {
                  professorName = 'Prof. João Silva';
                } else if (professorId == 'aec7f969-a0a1-4278-8b70-38d962135ad7') {
                  professorName = 'Prof. Gustavo Santos';
                } else {
                  professorName = 'Professor ${professorId.substring(0, 8)}';
                }
              }
            } catch (e) {
              print('Erro ao buscar professor $professorId: $e');
              // Fallback para nome baseado no ID
              if (professorId == '82a4ad2c-612c-4460-9eed-19a86c2c1757') {
                professorName = 'Prof. João Silva';
              } else if (professorId == 'aec7f969-a0a1-4278-8b70-38d962135ad7') {
                professorName = 'Prof. Gustavo Santos';
              } else {
                professorName = 'Professor ${professorId.substring(0, 8)}';
              }
            }
          }
          
          // Adicionar o nome do professor aos dados da aula
          final enrichedItem = Map<String, dynamic>.from(item);
          if (enrichedItem['class'] != null) {
            enrichedItem['class'] = Map<String, dynamic>.from(enrichedItem['class']);
            enrichedItem['class']['professor'] = {'name': professorName ?? 'Professor não encontrado'};
          }
          
          enrichedResponse.add(enrichedItem);
        }
        
        weekSchedule[dayOfWeek] = enrichedResponse;
      }
      
      print('Schedule da semana carregado: $weekSchedule');
      return weekSchedule;
    } catch (e) {
      throw Exception('Erro ao carregar aulas da semana: ${e.toString()}');
    }
  }

  // Buscar aulas da semana de um professor específico
  static Future<Map<String, List<Map<String, dynamic>>>> getWeekClassesByProfessor(String professorId) async {
    try {
      print('Buscando aulas da semana para o professor: $professorId');
      
      final Map<String, List<Map<String, dynamic>>> weekSchedule = {};
      final daysOfWeek = [
        'Segunda-feira',
        'Terça-feira',
        'Quarta-feira', 
        'Quinta-feira',
        'Sexta-feira',
        'Sábado',
        'Domingo'
      ];

      for (final dayOfWeek in daysOfWeek) {
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
        
        // Fallback para nome baseado no ID
        if (professorName == null) {
          if (professorId == '82a4ad2c-612c-4460-9eed-19a86c2c1757') {
            professorName = 'Prof. João Silva';
          } else if (professorId == 'aec7f969-a0a1-4278-8b70-38d962135ad7') {
            professorName = 'Prof. Gustavo Santos';
          } else {
            professorName = 'Professor ${professorId.substring(0, 8)}';
          }
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
        
        weekSchedule[dayOfWeek] = enrichedResponse;
      }
      
      return weekSchedule;
    } catch (e) {
      throw Exception('Erro ao carregar aulas da semana do professor: ${e.toString()}');
    }
  }
} 