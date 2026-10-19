import 'package:flutter/material.dart';
import '../models/trip_request.dart';
import '../services/api_service.dart';
import '../widgets/interest_chip_selector.dart';

class TripFormScreen extends StatefulWidget {
  const TripFormScreen({super.key});

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  final Set<String> _selectedInterests = {};
  final _apiService = ApiService();
  bool _isSubmitting = false;

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
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

  void _handleSubmit() async {
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

    setState(() => _isSubmitting = true);

    try {
      await for (final event in _apiService.planTrip(message: request.toMessage())) {
        debugPrint('SSE event: ${event.type} -> ${event.data}');
        
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: _isSubmitting ? null : _handleSubmit,
              icon: _isSubmitting
                  ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.explore_outlined),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_isSubmitting ? 'Planning...' : 'Plan My Trip'),
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