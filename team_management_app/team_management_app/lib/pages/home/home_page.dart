import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

/// Dit is de hoofdpagina die wordt weergegeven nadat de gebruiker is ingelogd.
class LoggedInHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Home'), // Aangepaste appbalk
      backgroundColor: const Color(0xFF121212), // Donkere achtergrondkleur
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centreer de inhoud
            children: [
              // Welkomsttekst
              const Text(
                'Welkom terug!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.cyan,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 40), // Ruimte tussen tekst en knoppen
              Wrap(
                spacing: 20, // Ruimte tussen knoppen horizontaal
                runSpacing: 20, // Ruimte tussen knoppen verticaal
                alignment: WrapAlignment.center, // Centreer de knoppen
                children: [
                  // Knop: Bekijk Teams
                  _buildActionButton(
                    context: context,
                    label: 'Bekijk Teams',
                    gradient: const LinearGradient(
                      colors: [Colors.cyan, Colors.teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    route: '/teams',
                  ),
                  // Knop: Maak Evenement
                  _buildActionButton(
                    context: context,
                    label: 'Maak Evenement',
                    gradient: const LinearGradient(
                      colors: [Colors.greenAccent, Colors.green],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    route: '/create-event',
                  ),
                  // Knop: Alle Teams en Gebruikers
                  _buildActionButton(
                    context: context,
                    label: 'Alle Teams en Gebruikers',
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.pinkAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    route: '/all-teams',
                  ),
                  // Knop: Alle Evenementen
                  _buildActionButton(
                    context: context,
                    label: 'Alle Evenementen',
                    gradient: const LinearGradient(
                      colors: [Colors.redAccent, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    route: '/all-events',
                  ),
                  // Knop: Alle Matches
                  _buildActionButton(
                    context: context,
                    label: 'Alle Matches',
                    gradient: const LinearGradient(
                      colors: [Colors.lightBlueAccent, Colors.blueGrey],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    route: '/all-matches',
                  ),
                  // Knop: Mijn Team Invites
                  _buildActionButton(
                    context: context,
                    label: 'Mijn Team Invites',
                    gradient: const LinearGradient(
                      colors: [Colors.cyan, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    route: '/team-invites',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bouwt een actieknop met een specifieke stijl, label en navigatieroute.
  Widget _buildActionButton({
    required BuildContext context, // Nodig voor navigatie
    required String label, // Tekst op de knop
    required Gradient gradient, // Achtergrondverloopkleur van de knop
    required String route, // Navigatieroute bij klikken
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route); // Navigeer naar de opgegeven route
      },
      child: Container(
        width: 160, // Breedte van de knop
        height: 60, // Hoogte van de knop
        decoration: BoxDecoration(
          gradient: gradient, // Stel de achtergrondverloopkleur in
          borderRadius: BorderRadius.circular(15), // Afronding van de hoeken
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25), // Schaduwkleur
              blurRadius: 10, // Hoe "wazig" de schaduw is
              offset: const Offset(0, 5), // Positie van de schaduw
            ),
          ],
        ),
        alignment: Alignment.center, // Centreer de tekst in de knop
        child: Text(
          label, // Tekst van de knop
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Kleur van de tekst
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
