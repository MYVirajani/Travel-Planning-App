import 'dart:convert';

enum TripPlanEventType { progress, result, error }

class TripPlanEvent {
  final TripPlanEventType type;
  final Map<String, dynamic> data;

  const TripPlanEvent({required this.type, required this.data});

  static TripPlanEventType _parseType(String raw) {
    switch (raw) {
      case 'progress':
        return TripPlanEventType.progress;
      case 'result':
        return TripPlanEventType.result;
      case 'error':
        return TripPlanEventType.error;
      default:
        throw FormatException('Unknown SSE event type: $raw');
    }
  }

  factory TripPlanEvent.fromRaw(String eventName, String dataJson) {
    final data = dataJson.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(dataJson) as Map<String, dynamic>;
    return TripPlanEvent(type: _parseType(eventName), data: data);
  }
}