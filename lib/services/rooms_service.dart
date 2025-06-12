import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room.dart';
import '../services/supabase_service.dart';

class RoomsService {
  static final _supabase = SupabaseService.client;

  static Future<List<Map<String, dynamic>>> getRooms() async {
    try {
      // Busca todos os campos relevantes da tabela rooms
      final response = await _supabase.from('rooms').select('*');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao carregar as salas: \u001b[${e.toString()}');
    }
  }

  // Função para buscar salas livres em um dia/horário específico
  static Future<List<Room>> getAvailableRoomsForSlot(String dayOfWeek, String timeSlot) async {
    try {
      // 1. Pega os IDs de todas as salas que JÁ ESTÃO OCUPADAS naquele horário
      final occupiedRoomsResponse = await _supabase
          .from('ensalamentos')
          .select('room_id')
          .eq('day_of_week', dayOfWeek)
          .eq('time_slot', timeSlot);
      
      final List<int> occupiedRoomIds = occupiedRoomsResponse
          .map<int>((item) => item['room_id'] as int)
          .toList();

      // 2. Busca todas as salas
      final allRoomsData = await getRooms();

      // 3. Filtra para retornar apenas as salas que NÃO ESTÃO na lista de ocupadas
      List<Map<String, dynamic>> availableRoomsData;
      if (occupiedRoomIds.isEmpty) {
        availableRoomsData = allRoomsData;
      } else {
        availableRoomsData = allRoomsData
            .where((room) => !occupiedRoomIds.contains(room['id']))
            .toList();
      }
      
      // Converte a lista de mapas para uma lista de objetos Room
      return availableRoomsData.map((json) => Room.fromJson(json)).toList();

    } catch (e) {
      throw Exception('Erro ao buscar salas disponíveis: [${e.toString()}');
    }
  }
} 