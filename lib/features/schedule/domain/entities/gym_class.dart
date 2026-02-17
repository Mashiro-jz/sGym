import 'package:equatable/equatable.dart';

class GymClass extends Equatable {
  final String id;
  final String name;
  final String description;
  final String trainerId;
  final DateTime startTime;
  final int durationMinutes;
  final int capacity;
  final List<String> registeredUserIds;

  const GymClass({
    required this.id,
    required this.name,
    required this.description,
    required this.trainerId,
    required this.startTime,
    required this.durationMinutes,
    required this.capacity,
    required this.registeredUserIds,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    trainerId,
    startTime,
    durationMinutes,
    capacity,
    registeredUserIds,
  ];
}
