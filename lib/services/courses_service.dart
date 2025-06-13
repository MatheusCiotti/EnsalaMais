import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/class.dart'; // É necessário importar o modelo de Class
import '../services/supabase_service.dart';

class CoursesService {
  static final _supabase = SupabaseService.client;

  // --- FUNÇÕES EXISTENTES (mantidas como estavam) ---

  // Buscar todos os cursos
  static Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final response = await _supabase
          .from('courses')
          .select('id, name, semester, period, coordinator, duration, description')
          .order('name');
      
      // Converter e filtrar dados válidos
      final result = <Map<String, dynamic>>[];
      for (var item in response) {
        if (item is Map<String, dynamic>) {
          // Verificar se os campos obrigatórios não são null
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

  // Buscar curso por ID
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

  // Atualizar um curso
  static Future<void> updateCourseWithClasses({
    required int id,
    required String name,
    required int semester,
    required String period,
    required String coordinator,
    required int duration,
    String? description,
    required List<String> classIds, // Recebe a nova lista de aulas
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
      throw Exception('Erro ao atualizar curso via RPC: [${e.toString()}');
    }
  }

  // Deletar um curso
  static Future<void> deleteCourse(int id) async {
    await _supabase
        .from('courses')
        .delete()
        .eq('id', id);
  }

  // --- FUNÇÕES NOVAS E MODIFICADAS ---

  // A função `createCourse` antiga foi substituída por esta:
  static Future<void> createCourseWithClasses({
    required String name,
    required int semester,
    required String period,
    required String coordinator,
    required int duration,
    String? description,
    required List<String> classIds, // Recebe a lista de IDs das aulas
  }) async {
    try {
      // Chama a função RPC segura que criamos no banco de dados
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
      // Propaga o erro para a UI poder mostrar uma mensagem
      throw Exception('Erro ao executar RPC create_course_with_classes: $e');
    }
  }

  // Nova função para buscar as aulas que aparecerão nos checkboxes
  static Future<List<Class>> getAvailableClasses() async {
    try {
      final response = await _supabase
          .from('classes')
          .select('*') // Seleciona todas as colunas
          .order('name');

      // Converte a lista de JSON para uma lista de objetos Class
      return response.map<Class>((json) => Class.fromJson(json)).toList();

    } catch (e) {
      throw Exception('Erro ao carregar aulas disponíveis: ${e.toString()}');
    }
  }

  // ===== NOVA FUNÇÃO ADICIONADA =====
  // Para buscar as aulas de um curso específico
  static Future<List<Class>> getClassesForCourse(int courseId) async {
    try {
      // Consulta corrigida para buscar a classe e os detalhes do curso ao qual ela pertence
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

      // Agora processamos a resposta para combinar os dados
      return response.map<Class>((item) {
        // Pega os dados da aula
        final classData = item['classes'] as Map<String, dynamic>;
        // Pega os dados do curso (que agora contém o semestre)
        final courseData = item['courses'] as Map<String, dynamic>?;

        // Adiciona manualmente o semestre aos dados da aula antes de converter
        classData['courseSemester'] = courseData?['semester'];
        
        return Class.fromJson(classData);
      }).toList();

    } catch (e) {
      throw Exception('Erro ao carregar as aulas do curso: ${e.toString()}');
    }
  }
}