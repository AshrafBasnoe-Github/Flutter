import 'package:flutter/material.dart';

class MatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final VoidCallback? onTap;

  const MatchCard({Key? key, required this.match, this.onTap}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: const Color(0xFF2A2A2A), // Donkere achtergrondkleur voor consistentie
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Afronding van de hoeken
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        title: Text(
          match['title'] ?? 'Geen titel',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Beschrijving: ${match['description'] ?? 'Geen beschrijving beschikbaar'}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            if (match.containsKey('datetimeStart'))
              Text(
                'Start: ${match['datetimeStart'] ?? 'N/A'}',
                style: const TextStyle(color: Colors.cyan),
              ),
            if (match.containsKey('datetimeEnd'))
              Text(
                'Eind: ${match['datetimeEnd'] ?? 'N/A'}',
                style: const TextStyle(color: Colors.cyan),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.cyan),

        onTap: onTap,
      ),
    );
  }
}
