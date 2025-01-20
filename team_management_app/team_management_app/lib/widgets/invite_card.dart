import 'package:flutter/material.dart';

class InviteCard extends StatelessWidget {
  final Map<String, dynamic> invite;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const InviteCard({
    Key? key,
    required this.invite,
    this.onAccept,
    this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: const Color(0xFF2A2A2A), // Donkere achtergrondkleur
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Afronding van de hoeken
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Titel
            Text(
              invite['matchTitle'] ?? 'Onbekende wedstrijd',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Teamnaam en status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Team: ${invite['teamName'] ?? 'Onbekend team'}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Status: ${invite['status'] ?? 'Onbekend'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: _getStatusColor(invite['status']),
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Knoppenrij
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: 'Accepteer Uitnodiging',
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check, color: Colors.white, size: 16),
                    label: const Text('Accepteren'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Weiger Uitnodiging',
                  child: ElevatedButton.icon(
                    onPressed: onDecline,
                    icon: const Icon(Icons.close, color: Colors.white, size: 16),
                    label: const Text('Weigeren'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Hulpmethode om statuskleur te bepalen
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'pending':
      default:
        return Colors.yellow;
    }
  }
}
