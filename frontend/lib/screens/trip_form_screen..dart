import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip_request.dart';
import '../models/trip_plan_state.dart';
import '../providers/trip_planner_provider.dart';
import '../widgets/interest_chip_selector.dart';

class TripFormScreen extends ConsumerStatefulWidget {
  const TripFormScreen({super.key});

  @override
  ConsumerState<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends ConsumerState<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  final Set<String> _selectedInterests = {};

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  String _formatDateRange() {
    if (_startDate == null || _endDate == null) return 'Select travel dates';
    String fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
    return '${fmt(_startDate!)} - ${fmt(_endDate!)}';
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select travel dates')),
      );
      return;
    }

    final request = TripRequest(
      destination: _destinationController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      budget: _budgetController.text.trim(),
      interests: _selectedInterests.toList(),
    );

    ref.read(tripPlannerProvider.notifier).planTrip(request.toMessage());
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(tripPlannerProvider);
    final isSubmitting = planState.status == TripPlanStatus.loading;

    ref.listen(tripPlannerProvider, (previous, next) {
      if (next.status == TripPlanStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: ${next.errorMessage}')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Plan Your Trip')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination',
                hintText: 'e.g. Kandy, Sri Lanka',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              (value == null || value.trim().isEmpty)
                  ? 'Please enter a destination'
                  : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDateRange,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Travel dates',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
                child: Text(_formatDateRange()),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetController,
              decoration: const InputDecoration(
                labelText: 'Budget',
                hintText: 'e.g. \$500',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              (value == null || value.trim().isEmpty)
                  ? 'Please enter a budget'
                  : null,
            ),
            const SizedBox(height: 24),
            Text('Interests', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            InterestChipSelector(
              selected: _selectedInterests,
              onToggle: (interest) {
                setState(() {
                  _selectedInterests.contains(interest)
                      ? _selectedInterests.remove(interest)
                      : _selectedInterests.add(interest);
                });
              },
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: isSubmitting ? null : _handleSubmit,
              icon: isSubmitting
                  ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.explore_outlined),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(isSubmitting
                    ? (planState.currentStepLabel ?? 'Planning...')
                    : 'Plan My Trip'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }
}