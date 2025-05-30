import 'package:supabase_flutter/supabase_flutter.dart';

class RoomsService {
  static final _supabase = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> getRooms() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('id, nome, descricao')
          .order('nome');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw 'Erro ao carregar salas: $e';
    }
  }
} 