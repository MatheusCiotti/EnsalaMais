import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/class.dart';

class ClassesService {
  static final _supabase = SupabaseService.client;

  // Buscar todas as aulas com informações do professor e sala
  static Future<List<Class>> getClasses() async {
    try {
      final response = await _supabase
          .from('classes')
          .select('''
            *,
            professor:users!professor_id(name),
            room:rooms!room_id(nome)
          ''')
          .order('name');

      return response.map<Class>((json) {
        // Adicionar os nomes do professor e sala ao JSON
        json['professor_name'] = json['professor']?['name'];
        json['room_name'] = json['room']?['nome'];
        return Class.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar aulas: ${e.toString()}');
    }
  }

  // Criar uma nova aula
  static Future<Class> createClass({
    required String name,
    required String professorId,
    String? observation,
    required String schedule,
    required int roomId,
  }) async {
    try {
      final response = await _supabase
          .from('classes')
          .insert({
            'name': name,
            'professor_id': professorId,
            'observation': observation,
            'schedule': schedule,
            'room_id': roomId,
          })
          .select('''
            *,
            professor:users!professor_id(name),
            room:rooms!room_id(nome)
          ''')
          .single();

      // Adicionar os nomes do professor e sala ao JSON
      response['professor_name'] = response['professor']?['name'];
      response['room_name'] = response['room']?['nome'];
      
      return Class.fromJson(response);
    } catch (e) {
      if (e.toString().contains('foreign key constraint')) {
        throw Exception('Professor ou sala não encontrados');
      }
      throw Exception('Erro ao criar aula: ${e.toString()}');
    }
  }

  // Atualizar uma aula
  static Future<Class> updateClass({
    required String id,
    required String name,
    required String professorId,
    String? observation,
    required String schedule,
    required int roomId,
  }) async {
    try {
      final response = await _supabase
          .from('classes')
          .update({
            'name': name,
            'professor_id': professorId,
            'observation': observation,
            'schedule': schedule,
            'room_id': roomId,
          })
          .eq('id', id)
          .select('''
            *,
            professor:users!professor_id(name),
            room:rooms!room_id(nome)
          ''')
          .single();

      // Adicionar os nomes do professor e sala ao JSON
      response['professor_name'] = response['professor']?['name'];
      response['room_name'] = response['room']?['nome'];
      
      return Class.fromJson(response);
    } catch (e) {
      if (e.toString().contains('foreign key constraint')) {
        throw Exception('Professor ou sala não encontrados');
      }
      throw Exception('Erro ao atualizar aula: ${e.toString()}');
    }
  }

  // Deletar uma aula
  static Future<void> deleteClass(String id) async {
    try {
      await _supabase
          .from('classes')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar aula: ${e.toString()}');
    }
  }

  // Buscar professores disponíveis
  static Future<List<Map<String, dynamic>>> getAvailableProfessors() async {
    try {
      final response = await _supabase
          .from('users')
          .select('id, name')
          .eq('role', 'Professor')
          .order('name');

      return response;
    } catch (e) {
      throw Exception('Erro ao carregar professores: ${e.toString()}');
    }
  }
} 