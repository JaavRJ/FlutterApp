import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';

class PlantStatus extends StatelessWidget {
  const PlantStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final plant = Provider.of<TaskProvider>(context).plant;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plant Status', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8.0),
            Text('Health Level: ${plant.healthLevel}'),
            Text('Water Level: ${plant.waterLevel}'),
            Text('Reward Points: ${plant.rewardPoints}'),
            Text('Last Watered: ${plant.lastWatered}'),
          ],
        ),
      ),
    );
  }
}
