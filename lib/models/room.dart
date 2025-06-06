// import 'room_equipment.dart'; // Mantive comentado pois não tenho o arquivo

class Room {
  final int id;
  final String nome;
  final String? descricao;
  final int block_id; // <-- ADICIONADO: Para vincular a sala a um bloco.
  final bool hasAirConditioning;
  final bool hasProjector;
  final bool hasTV;

  Room({
    required this.id,
    required this.nome,
    required this.block_id, // <-- ADICIONADO: Agora é obrigatório no construtor.
    this.descricao,
    this.hasAirConditioning = false,
    this.hasProjector = false,
    this.hasTV = false,
  });

  // Construtor factory para criar uma sala a partir de um JSON vindo do DB
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
      block_id: json['block_id'] as int, // <-- ADICIONADO: Lê o 'block_id' do JSON.
      hasAirConditioning: json['has_air_conditioning'] as bool? ?? false,
      hasProjector: json['has_projector'] as bool? ?? false,
      hasTV: json['has_tv'] as bool? ?? false,
    );
  }

  // Método para converter o objeto Room em um Map (JSON) para enviar ao DB
  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // <-- REMOVIDO: Não se envia o ID ao criar um novo item, o banco gera automaticamente.
      'nome': nome,
      'descricao': descricao,
      'block_id': block_id, // <-- ADICIONADO: Envia o 'block_id' para o banco.
      'has_air_conditioning': hasAirConditioning,
      'has_projector': hasProjector,
      'has_tv': hasTV,
    };
  }

  // Método auxiliar para criar uma cópia do objeto com valores diferentes
  Room copyWith({
    int? id,
    String? nome,
    String? descricao,
    int? block_id, // <-- ADICIONADO
    bool? hasAirConditioning,
    bool? hasProjector,
    bool? hasTV,
  }) {
    return Room(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      block_id: block_id ?? this.block_id, // <-- ADICIONADO
      hasAirConditioning: hasAirConditioning ?? this.hasAirConditioning,
      hasProjector: hasProjector ?? this.hasProjector,
      hasTV: hasTV ?? this.hasTV,
    );
  }
}