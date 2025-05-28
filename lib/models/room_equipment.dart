class RoomEquipment {
  final bool hasAirConditioning;
  final bool hasProjector;
  final bool hasTV;

  RoomEquipment({
    this.hasAirConditioning = false,
    this.hasProjector = false,
    this.hasTV = false,
  });

  factory RoomEquipment.fromJson(Map<String, dynamic> json) {
    return RoomEquipment(
      hasAirConditioning: json['has_air_conditioning'] as bool? ?? false,
      hasProjector: json['has_projector'] as bool? ?? false,
      hasTV: json['has_tv'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_air_conditioning': hasAirConditioning,
      'has_projector': hasProjector,
      'has_tv': hasTV,
    };
  }
} 