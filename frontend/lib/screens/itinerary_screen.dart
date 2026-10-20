import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trip_planner_provider.dart';
import '../widgets/itinerary_day_card.dart';

class ItineraryScreen extends ConsumerStatefulWidget {
  const ItineraryScreen({super.key});

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(tripPlannerProvider);
    final itinerary = planState.itinerary ?? [];

    if (itinerary.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No itinerary available')),
      );
    }

    final selectedDay = itinerary[_selectedDayIndex];

    return Scaffold(
      appBar: AppBar(title: Text(planState.destination ?? 'Your Trip')),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: itinerary.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedDayIndex;
                return ChoiceChip(
                  label: Text('Day ${itinerary[index].dayNumber}'),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedDayIndex = index),
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  selectedDay.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ...selectedDay.activities.map(
                      (activity) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ItineraryDayCard(activity: activity),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}