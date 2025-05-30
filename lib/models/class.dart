import 'package:flutter/material.dart';

class Class {
  final String id;
  final String name;
  final String professorId;
  final String? observation;
  final String schedule;
  final int roomId;
  final DateTime createdAt;
  String? professorName; // Nome do professor (carregado separadamente)
  String? roomName; // Nome da sala (carregado separadamente)

  Class({
    required this.id,
    required this.name,
    required this.professorId,
    this.observation,
    required this.schedule,
    required this.roomId,
    required this.createdAt,
    this.professorName,
    this.roomName,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      professorId: json['professor_id'] ?? '',
      observation: json['observation'],
      schedule: json['schedule'] ?? '',
      roomId: json['room_id'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      professorName: json['professor_name'],
      roomName: json['room_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'professor_id': professorId,
      'observation': observation,
      'schedule': schedule,
      'room_id': roomId,
    };
  }
} 