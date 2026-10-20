import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/itinerary.dart';
import '../models/trip_plan_event.dart';
import '../models/trip_plan_state.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final tripPlannerProvider =
StateNotifierProvider<TripPlannerNotifier, TripPlanState>((ref) {
  return TripPlannerNotifier(ref.read(apiServiceProvider));
});

class TripPlannerNotifier extends StateNotifier<TripPlanState> {
  final ApiService _apiService;

  TripPlannerNotifier(this._apiService) : super(const TripPlanState());

  Future<void> planTrip(String message) async {
    state = const TripPlanState(status: TripPlanStatus.loading);

    try {
      await for (final event in _apiService.planTrip(message: message)) {
        switch (event.type) {
          case TripPlanEventType.progress:
            state = state.copyWith(
              status: TripPlanStatus.loading,
              currentStepLabel: event.data['label'] as String?,
            );
            break;

          case TripPlanEventType.result:
            final days = (event.data['itinerary'] as List? ?? [])
                .map((d) => ItineraryDay(
              dayNumber: d['day_number'] as int,
              title: d['title'] as String,
              activities: (d['activities'] as List)
                  .map((a) => ItineraryActivity(
                timeOfDay: a['time_of_day'] as String,
                placeName: a['place_name'] as String,
                description: a['description'] as String,
              ))
                  .toList(),
            ))
                .toList();

            state = state.copyWith(
              status: TripPlanStatus.success,
              destination: event.data['destination'] as String?,
              itinerary: days,
            );
            break;

          case TripPlanEventType.error:
            state = state.copyWith(
              status: TripPlanStatus.error,
              errorMessage: event.data['message'] as String?,
            );
            break;
        }
      }
    } catch (e) {
      state = state.copyWith(
        status: TripPlanStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const TripPlanState();
}