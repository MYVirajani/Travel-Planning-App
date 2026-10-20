import 'itinerary.dart';

enum TripPlanStatus { idle, loading, success, error }

class TripPlanState {
  final TripPlanStatus status;
  final String? currentStepLabel;
  final String? destination;
  final List<ItineraryDay>? itinerary;
  final String? errorMessage;

  const TripPlanState({
    this.status = TripPlanStatus.idle,
    this.currentStepLabel,
    this.destination,
    this.itinerary,
    this.errorMessage,
  });

  TripPlanState copyWith({
    TripPlanStatus? status,
    String? currentStepLabel,
    String? destination,
    List<ItineraryDay>? itinerary,
    String? errorMessage,
  }) {
    return TripPlanState(
      status: status ?? this.status,
      currentStepLabel: currentStepLabel ?? this.currentStepLabel,
      destination: destination ?? this.destination,
      itinerary: itinerary ?? this.itinerary,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}