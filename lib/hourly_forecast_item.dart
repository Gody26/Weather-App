import 'package:flutter/material.dart';

class HourlyForecastItem extends StatelessWidget {
  final String time;
  final String value;
  final IconData icon;
  const HourlyForecastItem({
    super.key,
    required this.time,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Container(
        width: 85,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              time,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Icon(icon, size: 25),
            const SizedBox(height: 5),
            Text(
              value,
            ),
          ],
        ),
      ),
    );
  }
}
