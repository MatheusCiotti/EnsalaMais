import 'room_equipment.dart';

class Room {
  final int id;
  final int blockId;
  final String number;
  final int capacity;
  final String? description;
  final RoomEquipment equipment;

  Room({
    required this.id,
    required this.blockId,
    required this.number,
    required this.capacity,
    this.description,
    RoomEquipment? equipment,
  }) : equipment = equipment ?? RoomEquipment();

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as int,
      blockId: json['block_id'] as int,
      number: json['number'] as String,
      capacity: json['capacity'] as int,
      description: json['description'] as String?,
      equipment: RoomEquipment.fromJson(json['equipment'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'block_id': blockId,
      'number': number,
      'capacity': capacity,
      'description': description,
      'equipment': equipment.toJson(),
    };
  }

  Room copyWith({
    int? id,
    int? blockId,
    String? number,
    int? capacity,
    String? description,
    RoomEquipment? equipment,
  }) {
    return Room(
      id: id ?? this.id,
      blockId: blockId ?? this.blockId,
      number: number ?? this.number,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      equipment: equipment ?? this.equipment,
    );
  }
} 