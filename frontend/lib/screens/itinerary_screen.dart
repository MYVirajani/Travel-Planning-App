import 'package:flutter/material.dart';
import '../models/itinerary.dart';

class ItineraryScreen extends StatelessWidget {
  final String destination;
  final List<ItineraryDay> itinerary;

  const ItineraryScreen({
    super.key,
    required this.destination,
    required this.itinerary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(destination)),
      body: const Center(
        child: Text('Visual itinerary cards '),
      ),
    );
  }
}