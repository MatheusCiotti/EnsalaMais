import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class BlocksService {
  static final _supabase = SupabaseService.client;

  // Buscar todos os blocos
  static Future<List<Map<String, dynamic>>> getBlocks() async {
    final response = await _supabase
        .from('blocks')
        .select('*')
        .order('name');
    
    return List<Map<String, dynamic>>.from(response);
  }

  // Criar um novo bloco
  static Future<Map<String, dynamic>> createBlock({
    required String name,
    required int totalRooms,
    required int totalCapacity,
  }) async {
    final response = await _supabase
        .from('blocks')
        .insert({
          'name': name,
          'total_rooms': totalRooms,
          'total_capacity': totalCapacity,
        })
        .select()
        .single();
    
    return response;
  }

  // Atualizar um bloco
  static Future<Map<String, dynamic>> updateBlock({
    required int id,
    required String name,
    required int totalRooms,
    required int totalCapacity,
  }) async {
    final response = await _supabase
        .from('blocks')
        .update({
          'name': name,
          'total_rooms': totalRooms,
          'total_capacity': totalCapacity,
        })
        .eq('id', id)
        .select()
        .single();
    
    return response;
  }

  // Deletar um bloco
  static Future<void> deleteBlock(int id) async {
    await _supabase
        .from('blocks')
        .delete()
        .eq('id', id);
  }

  // Buscar salas de um bloco
  static Future<List<Map<String, dynamic>>> getRooms(int blockId) async {
    final response = await _supabase
        .from('rooms')
        .select('*')
        .eq('block_id', blockId)
        .order('number');
    
    return List<Map<String, dynamic>>.from(response);
  }

  // Criar uma nova sala
  static Future<Map<String, dynamic>> createRoom({
    required int blockId,
    required String number,
    required int capacity,
    String? description,
  }) async {
    final response = await _supabase
        .from('rooms')
        .insert({
          'block_id': blockId,
          'number': number,
          'capacity': capacity,
          'description': description,
        })
        .select()
        .single();
    
    return response;
  }

  // Atualizar uma sala
  static Future<Map<String, dynamic>> updateRoom({
    required int id,
    required String number,
    required int capacity,
    String? description,
  }) async {
    final response = await _supabase
        .from('rooms')
        .update({
          'number': number,
          'capacity': capacity,
          'description': description,
        })
        .eq('id', id)
        .select()
        .single();
    
    return response;
  }

  // Deletar uma sala
  static Future<void> deleteRoom(int id) async {
    await _supabase
        .from('rooms')
        .delete()
        .eq('id', id);
  }
} 