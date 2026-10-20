import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip_plan_state.dart';
import '../providers/trip_planner_provider.dart';
import 'itinerary_screen.dart';

class LoadingScreen extends ConsumerWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(tripPlannerProvider, (previous, next) {
      if (next.status == TripPlanStatus.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ItineraryScreen()),
        );
      } else if (next.status == TripPlanStatus.error) {
        Navigator.pop(context); // back to form
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: ${next.errorMessage}')),
        );
      }
    });

    final planState = ref.watch(tripPlannerProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              planState.currentStepLabel ?? 'Getting started...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}