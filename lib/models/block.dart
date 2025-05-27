class Block {
  final int id;
  final String name;
  final int totalRooms;
  final int totalCapacity;

  Block({
    required this.id,
    required this.name,
    required this.totalRooms,
    required this.totalCapacity,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      id: json['id'] as int,
      name: json['name'] as String,
      totalRooms: json['total_rooms'] as int,
      totalCapacity: json['total_capacity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'total_rooms': totalRooms,
      'total_capacity': totalCapacity,
    };
  }
} 