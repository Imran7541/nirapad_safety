import 'safety_mode.dart';

class IncidentModel {
  final String id;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String address;
  final SafetyMode mode;
  final String status; // 'countdown', 'dispatched', 'resolved', 'cancelled'
  final int batteryLevel;
  final double speedKmh;
  final String notes;
  final bool isDuressAlarm;

  const IncidentModel({
    required this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.mode,
    required this.status,
    required this.batteryLevel,
    required this.speedKmh,
    this.notes = '',
    this.isDuressAlarm = false,
  });

  String get mapsUrl => 'https://maps.google.com/?q=$latitude,$longitude';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'mode': mode.name,
      'status': status,
      'battery_level': batteryLevel,
      'speed_kmh': speedKmh,
      'notes': notes,
      'is_duress_alarm': isDuressAlarm ? 1 : 0,
    };
  }

  factory IncidentModel.fromMap(Map<String, dynamic> map) {
    return IncidentModel(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: (map['address'] as String?) ?? '',
      mode: SafetyMode.values.firstWhere(
        (e) => e.name == map['mode'],
        orElse: () => SafetyMode.women,
      ),
      status: (map['status'] as String?) ?? 'dispatched',
      batteryLevel: (map['battery_level'] as int?) ?? 100,
      speedKmh: (map['speed_kmh'] as num?)?.toDouble() ?? 0.0,
      notes: (map['notes'] as String?) ?? '',
      isDuressAlarm: (map['is_duress_alarm'] as int?) == 1,
    );
  }
}
