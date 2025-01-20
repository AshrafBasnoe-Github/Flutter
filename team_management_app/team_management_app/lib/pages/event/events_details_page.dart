import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_management_app/services/api_service.dart';
import 'edit_event_page.dart';

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> event; // Het evenement waarvan de details worden weergegeven
  final VoidCallback onDelete; // Callback voor het verwijderen van het evenement
  final VoidCallback onUpdate; // Callback voor het bijwerken van het evenement

  const EventDetailsPage({
    Key? key,
    required this.event,
    required this.onDelete,
    required this.onUpdate, // Callback om updates te verwerken
  }) : super(key: key);

  // Methode om een evenement te verwijderen
  Future<void> deleteEvent(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Haal de token op

    if (token == null) {
      // Als er geen token beschikbaar is, vraag de gebruiker opnieuw in te loggen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geen token beschikbaar. Log in opnieuw.')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      return;
    }

    try {
      // Roep de API aan om het evenement te verwijderen
      final response = await ApiService.deleteEvent(event['id'], token);

      if (response) {
        // Als succesvol, toon een melding en roep de `onDelete` callback aan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evenement succesvol verwijderd!')),
        );
        onDelete();
        Navigator.pop(context); // Navigeer terug na verwijderen
      } else {
        // Toon een foutmelding als verwijderen mislukt
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fout bij het verwijderen van het evenement.')),
        );
      }
    } catch (e) {
      // Foutafhandeling bij een uitzondering
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout: $e')),
      );
    }
  }

  // Methode om een datum-tijdstring te formatteren
  String formatDateTime(String dateTime) {
    final date = DateTime.parse(dateTime); // Parseer de string naar een DateTime-object
    return '${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}'; // Geef het formaat terug
  }

  @override
  Widget build(BuildContext context) {
    // Controleer of de gebruiker de beheerder is van het evenement
    final isAdmin = event['team']['ownerId'] == event['createdBy'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          event['title'] ?? 'Evenement Details', // Toon de titel van het evenement
          style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A1A), // Donkere achtergrondkleur
      ),
      backgroundColor: const Color(0xFF1A1A1A), // Donkere achtergrondkleur voor de body
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titel van het evenement
            Text(
              'Titel: ${event['title'] ?? 'Onbekend'}',
              style: const TextStyle(fontSize: 22, color: Colors.cyan, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Beschrijving van het evenement
            Text(
              'Beschrijving: ${event['description'] ?? 'Geen beschrijving beschikbaar'}',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),
            // Startdatum en tijd
            Text(
              'Start: ${formatDateTime(event['datetimeStart'])}',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            // Einddatum en tijd
            Text(
              'Einde: ${formatDateTime(event['datetimeEnd'])}',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),
            // Naam van het team
            Text(
              'Team: ${event['team']['name'] ?? 'Onbekend Team'}',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),
            // Eventuele instructies
            Text(
              'Instructies: ${event['metadata']['instructions'] ?? 'Geen instructies'}',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 32),
            // Knoppen voor beheren (alleen zichtbaar voor beheerders)
            if (isAdmin)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Verwijderen-knop
                  ElevatedButton(
                    onPressed: () => deleteEvent(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Rode kleur voor verwijderknop
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Verwijder Evenement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Bewerken-knop
                  ElevatedButton(
                    onPressed: () async {
                      // Navigeer naar de `EditEventPage`
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditEventPage(
                            event: event, // Geef het evenement door
                            onUpdate: onUpdate, // Callback voor updates
                          ),
                        ),
                      );
                      if (result == true) {
                        // Als het evenement is bijgewerkt, roep de `onUpdate` callback aan
                        onUpdate();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Blauwe kleur voor bewerken
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Bewerk Evenement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
}
