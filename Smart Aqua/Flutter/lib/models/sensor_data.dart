class SensorData {
  final double value;
  final DateTime timestamp;

  SensorData(this.value, this.timestamp);

  factory SensorData.fromMap(Map<dynamic, dynamic> map) {
    return SensorData(
      double.parse(map['value'].toString()),
      DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}

class AquascapeStatus {
  final double ph;
  final double temperature;
  final double clarity;
  final double lux;
  final DateTime timestamp;

  AquascapeStatus({
    required this.ph,
    required this.temperature,
    required this.clarity,
    required this.lux,
    required this.timestamp,
  });

  factory AquascapeStatus.fromMap(Map<dynamic, dynamic> map) {
    return AquascapeStatus(
      ph: double.parse(map['ph'].toString()),
      temperature: double.parse(map['temperature'].toString()),
      clarity: double.parse(map['clarity'].toString()),
      lux: double.parse(map['lux'].toString()),
      timestamp: DateTime.now(),
    );
  }
} 