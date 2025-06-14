import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/class.dart';
import '../services/supabase_service.dart';

class CoursesService {
  static final _supabase = SupabaseService.client;

  static Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final response = await _supabase
          .from('courses')
          .select('id, name, semester, period, coordinator, duration, description')
          .order('name');
      
      final result = <Map<String, dynamic>>[];
      for (var item in response) {
        if (item is Map<String, dynamic>) {
          if (item['id'] != null && item['name'] != null) {
            result.add({
              'id': item['id'],
              'name': item['name'] ?? 'Curso sem nome',
              'semester': item['semester'] ?? 1,
              'period': item['period'] ?? 'Não definido',
              'coordinator': item['coordinator'] ?? 'Não definido',
              'duration': item['duration'] ?? 1,
              'description': item['description'],
            });
          }
        }
      }
      
      return result;
    } catch (e) {
      throw Exception('Erro ao carregar cursos: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>?> getCourseById(int courseId) async {
    try {
      final response = await _supabase
          .from('courses')
          .select('*')
          .eq('id', courseId)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Erro ao carregar curso: ${e.toString()}');
    }
  }

  static Future<void> updateCourseWithClasses({
    required int id,
    required String name,
    required int semester,
    required String period,
    required String coordinator,
    required int duration,
    String? description,
    required List<String> classIds,
  }) async {
    try {
      await _supabase.rpc('update_course_with_classes', params: {
        'course_id_to_update': id,
        'course_name': name,
        'course_semester': semester,
        'course_period': period,
        'course_coordinator': coordinator,
        'course_duration': duration,
        'course_description': description,
        'class_ids': classIds,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar curso via RPC: [${e.toString()}');
    }
  }

  static Future<void> deleteCourse(int id) async {
    await _supabase
        .from('courses')
        .delete()
        .eq('id', id);
  }

  static Future<void> createCourseWithClasses({
    required String name,
    required int semester,
    required String period,
    required String coordinator,
    required int duration,
    String? description,
    required List<String> classIds,
  }) async {
    try {
      await _supabase.rpc('create_course_with_classes', params: {
        'course_name': name,
        'course_semester': semester,
        'course_period': period,
        'course_coordinator': coordinator,
        'course_duration': duration,
        'course_description': description,
        'class_ids': classIds,
      });
    } catch (e) {
      throw Exception('Erro ao executar RPC create_course_with_classes: $e');
    }
  }

  static Future<List<Class>> getAvailableClasses() async {
    try {
      final response = await _supabase
          .from('classes')
          .select('*')
          .order('name');

      return response.map<Class>((json) => Class.fromJson(json)).toList();

    } catch (e) {
      throw Exception('Erro ao carregar aulas disponíveis: ${e.toString()}');
    }
  }

  static Future<List<Class>> getClassesForCourse(int courseId) async {
    try {
      final response = await _supabase
          .from('course_classes')
          .select('''
            classes!inner(*, professor:users(name)),
            courses!inner(semester)
          ''')
          .eq('course_id', courseId);

      if (response.isEmpty) {
        return [];
      }

      return response.map<Class>((item) {
        final classData = item['classes'] as Map<String, dynamic>;
        final courseData = item['courses'] as Map<String, dynamic>?;

        classData['courseSemester'] = courseData?['semester'];
        
        return Class.fromJson(classData);
      }).toList();

    } catch (e) {
      throw Exception('Erro ao carregar as aulas do curso: ${e.toString()}');
    }
  }
}