import 'package:flutter/material.dart';

class InterestChipSelector extends StatelessWidget {
  static const availableInterests = [
    'Temples', 'Hiking', 'Beaches', 'Food', 'Nightlife',
    'Shopping', 'Museums', 'Nature', 'Adventure', 'Relaxation',
  ];

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const InterestChipSelector({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableInterests.map((interest) {
        final isSelected = selected.contains(interest);
        return FilterChip(
          label: Text(interest),
          selected: isSelected,
          onSelected: (_) => onToggle(interest),
        );
      }).toList(),
    );
  }
}