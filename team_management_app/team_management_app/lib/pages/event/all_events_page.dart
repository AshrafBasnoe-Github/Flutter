import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_management_app/services/api_service.dart';
import 'events_details_page.dart';

class AllEventsPage extends StatefulWidget {
  @override
  _AllEventsPageState createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  List<dynamic> events = []; // Opslag voor de lijst met evenementen
  bool isLoading = false; // Status voor het tonen van een laadindicator

  @override
  void initState() {
    super.initState();
    fetchEvents(); // Haal de evenementen op bij het starten van de pagina
  }

  // Functie om evenementen op te halen via de API
  Future<void> fetchEvents() async {
    setState(() {
      isLoading = true; // Zet de laadindicator aan
    });

    try {
      final prefs = await SharedPreferences.getInstance(); // Toegang tot gedeelde voorkeuren
      final token = prefs.getString('token'); // Haal de opgeslagen token op

      if (token == null) {
        // Als er geen token is, vraag de gebruiker opnieuw in te loggen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geen token beschikbaar. Log in opnieuw.')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      // Haal evenementen op via de ApiService
      final fetchedEvents = await ApiService.getAllEvents(token);
      setState(() {
        events = fetchedEvents; // Sla de opgehaalde evenementen op
      });
    } catch (e) {
      // Toon een foutmelding als er een probleem is
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij het ophalen van evenementen: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Zet de laadindicator uit
      });
    }
  }

  // Functie om de evenementenlijst opnieuw op te halen
  void refreshEvents() {
    fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alle Evenementen', // Titel van de pagina
          style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A1A), // Donkere achtergrondkleur
      ),
      backgroundColor: const Color(0xFF1A1A1A), // Donkere achtergrondkleur voor de body
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyan), // Laadindicator
            )
          : events.isEmpty
              ? const Center(
                  child: Text(
                    'Geen evenementen beschikbaar.', // Bericht als er geen evenementen zijn
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: events.length, // Aantal evenementen in de lijst
                  itemBuilder: (context, index) {
                    final event = events[index]; // Haal het huidige evenement op
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Marges rond de kaart
                      color: const Color(0xFF2A2A2A), // Donkere kleur voor de kaart
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Afgeronde hoeken
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        title: Text(
                          event['title'] ?? 'Onbekend Evenement', // Titel van het evenement
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          // Startdatum van het evenement, indien beschikbaar
                          event['datetimeStart'] != null
                              ? 'Start: ${DateTime.parse(event['datetimeStart']).toLocal()}'
                              : 'Geen starttijd beschikbaar',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.cyan), // Pijl-icoon
                        onTap: () {
                          // Navigeren naar de details van het evenement
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailsPage(
                                event: event, // Het huidige evenement
                                onDelete: refreshEvents, // Functie om de lijst te vernieuwen na verwijdering
                                onUpdate: refreshEvents, // Functie om de lijst te vernieuwen na een update
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
