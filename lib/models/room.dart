// lib/models/room.dart

class Room {
  final int id;
  final String? nome;
  final String? descricao;

  // CORREÇÃO: Propriedades alteradas para camelCase e/ou para aceitar nulos
  final int? blockId; // Alterado para camelCase e agora pode ser nulo (int?)
  final bool hasAirConditioning;
  final bool hasProjector;
  final bool hasTV;

  Room({
    required this.id,
    this.nome,
    this.descricao,
    this.blockId, // Agora é opcional
    required this.hasAirConditioning,
    required this.hasProjector,
    required this.hasTV,
  });

  // Construtor factory corrigido para ser à prova de falhas
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      // Chave primária não deve ser nula, então mantemos a conversão direta
      id: json['id'] as int,
      nome: json['nome'] as String?,
      descricao: json['descricao'] as String?,
      
      // CORREÇÃO: Converte 'block_id' para int anulável (int?)
      blockId: json['block_id'] as int?, 
      
      // CORREÇÃO: Garante um valor padrão 'false' se os campos booleanos forem nulos
      hasAirConditioning: json['has_air_conditioning'] as bool? ?? false,
      hasProjector: json['has_projector'] as bool? ?? false,
      hasTV: json['has_tv'] as bool? ?? false,
    );
  }

  // Método para converter o objeto em JSON para enviar ao Supabase
  Map<String, dynamic> toJson() {
    return {
      // O ID não é enviado na criação, mas pode ser útil em atualizações
      'id': id, 
      'nome': nome,
      'descricao': descricao,
      'block_id': blockId, // Usa a propriedade camelCase
      'has_air_conditioning': hasAirConditioning,
      'has_projector': hasProjector,
      'has_tv': hasTV,
    };
  }
  
  // O método copyWith não é estritamente necessário para o erro atual,
  // mas é uma boa prática mantê-lo atualizado com o modelo.
  Room copyWith({
    int? id,
    String? nome,
    String? descricao,
    int? blockId,
    bool? hasAirConditioning,
    bool? hasProjector,
    bool? hasTV,
  }) {
    return Room(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      blockId: blockId ?? this.blockId,
      hasAirConditioning: hasAirConditioning ?? this.hasAirConditioning,
      hasProjector: hasProjector ?? this.hasProjector,
      hasTV: hasTV ?? this.hasTV,
    );
  }
}