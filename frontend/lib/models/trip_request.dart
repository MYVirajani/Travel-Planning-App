class TripRequest {
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String budget;
  final List<String> interests;

  const TripRequest({
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.interests,
  });
  
  String toMessage() {
    final days = endDate.difference(startDate).inDays + 1;
    final interestStr = interests.isEmpty ? 'general sightseeing' : interests.join(', ');
    return '$days-day trip to $destination, budget $budget, interested in $interestStr';
  }
}