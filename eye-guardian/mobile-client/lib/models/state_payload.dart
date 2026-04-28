class StatePayload {
  final String userId;
  final String clientId;
  final int timestamp;
  final int petLevel;
  final double healthScore;
  final int accumulatedFatigue;
  final String currentStatus;
  final int lastBreakDuration;

  StatePayload({
    required this.userId,
    required this.clientId,
    required this.timestamp,
    required this.petLevel,
    required this.healthScore,
    required this.accumulatedFatigue,
    required this.currentStatus,
    required this.lastBreakDuration,
  });

  factory StatePayload.fromJson(Map<String, dynamic> json) => StatePayload(
        userId: json['user_id'] ?? '',
        clientId: json['client_id'] ?? '',
        timestamp: json['timestamp'] ?? 0,
        petLevel: json['pet_level'] ?? 1,
        healthScore: (json['health_score'] ?? 100).toDouble(),
        accumulatedFatigue: json['accumulated_fatigue'] ?? 0,
        currentStatus: json['current_status'] ?? 'active',
        lastBreakDuration: json['last_break_duration'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'client_id': clientId,
        'timestamp': timestamp,
        'pet_level': petLevel,
        'health_score': healthScore,
        'accumulated_fatigue': accumulatedFatigue,
        'current_status': currentStatus,
        'last_break_duration': lastBreakDuration,
      };
}
