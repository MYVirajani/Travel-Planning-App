class ItineraryActivity {
  final String timeOfDay;
  final String placeName;
  final String description;

  const ItineraryActivity({
    required this.timeOfDay,
    required this.placeName,
    required this.description,
  });
}

class ItineraryDay {
  final int dayNumber;
  final String title;
  final List<ItineraryActivity> activities;

  const ItineraryDay({
    required this.dayNumber,
    required this.title,
    required this.activities,
  });
}