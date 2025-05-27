class Room {
  final int id;
  final int blockId;
  final String number;
  final int capacity;
  final String? description;

  Room({
    required this.id,
    required this.blockId,
    required this.number,
    required this.capacity,
    this.description,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as int,
      blockId: json['block_id'] as int,
      number: json['number'] as String,
      capacity: json['capacity'] as int,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'block_id': blockId,
      'number': number,
      'capacity': capacity,
      'description': description,
    };
  }
} 