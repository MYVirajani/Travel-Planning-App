import 'package:flutter/material.dart';
import 'package:frontend/screens/trip_form_screen..dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  static const _destinations = [
    Destination(name: 'Kandy', country: 'Sri Lanka', imageQuery: 'kandy sri lanka temple'),
    Destination(name: 'Bali', country: 'Indonesia', imageQuery: 'bali rice terrace'),
    Destination(name: 'Kyoto', country: 'Japan', imageQuery: 'kyoto temple autumn'),
    Destination(name: 'Santorini', country: 'Greece', imageQuery: 'santorini blue domes'),
    Destination(name: 'Queenstown', country: 'New Zealand', imageQuery: 'queenstown mountains lake'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('Explore'),
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Popular destinations',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                    DestinationCard(destination: _destinations[index]),
                childCount: _destinations.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TripFormScreen()),
          );
        },
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Plan a trip'),
      ),
    );
  }
}