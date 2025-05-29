import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class CoursesService {
  static final _supabase = SupabaseService.client;

  // Buscar todos os cursos
  static Future<List<Map<String, dynamic>>> getCourses() async {
    final response = await _supabase
        .from('courses')
        .select('*')
        .order('name');
    
    return List<Map<String, dynamic>>.from(response);
  }

  // Criar um novo curso
  static Future<Map<String, dynamic>> createCourse({
    required String name,
    required int semester,
    required String period,
    required String coordinator,
    required int duration,
    String? description,
  }) async {
    final response = await _supabase
        .from('courses')
        .insert({
          'name': name,
          'semester': semester,
          'period': period,
          'coordinator': coordinator,
          'duration': duration,
          'description': description,
        })
        .select()
        .single();
    
    return response;
  }

  // Atualizar um curso
  static Future<Map<String, dynamic>> updateCourse({
    required int id,
    required String name,
    required int semester,
    required String period,
    required String coordinator,
    required int duration,
    String? description,
  }) async {
    final response = await _supabase
        .from('courses')
        .update({
          'name': name,
          'semester': semester,
          'period': period,
          'coordinator': coordinator,
          'duration': duration,
          'description': description,
        })
        .eq('id', id)
        .select()
        .single();
    
    return response;
  }

  // Deletar um curso
  static Future<void> deleteCourse(int id) async {
    await _supabase
        .from('courses')
        .delete()
        .eq('id', id);
  }
} 