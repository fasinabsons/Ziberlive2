import 'package:flutter/material.dart';

class TipCard extends StatelessWidget {
  final dynamic tip;
  
  const TipCard({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sample Tip',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This is a sample tip from the community.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_up_outlined),
                  color: Colors.green,
                ),
                const Text('5'),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_down_outlined),
                  color: Colors.red,
                ),
                const Text('0'),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 