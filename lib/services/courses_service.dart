import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/class.dart'; // É necessário importar o modelo de Class
import '../services/supabase_service.dart';

class CoursesService {
  static final _supabase = SupabaseService.client;

  // --- FUNÇÕES EXISTENTES (mantidas como estavam) ---

  // Buscar todos os cursos
  static Future<List<Map<String, dynamic>>> getCourses() async {
    final response = await _supabase
        .from('courses')
        .select('*')
        .order('name');
    
    return List<Map<String, dynamic>>.from(response);
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
      // Busca na tabela de ligação 'course_classes'
      final response = await _supabase
          .from('course_classes')
          // Pede para trazer todos os dados (*) da tabela 'classes' relacionada
          .select('classes(*)') 
          .eq('course_id', courseId);

      // A resposta virá como uma lista de: [{'classes': { ...dados da aula... }}]
      if (response.isEmpty) {
        return [];
      }

      // Extrai o objeto 'classes' de dentro de cada item.
      final classDataList = response.map((item) {
        // Verificação de segurança para o caso de 'classes' ser nulo
        return item['classes'] as Map<String, dynamic>?;
      }).where((item) => item != null).toList(); // Filtra qualquer item nulo
      
      // Agora convertemos a lista de dados de aulas para uma lista de objetos Class
      return classDataList.map<Class>((json) => Class.fromJson(json!)).toList();

    } catch (e) {
      throw Exception('Erro ao carregar as aulas do curso: [${e.toString()}');
    }
  }
}