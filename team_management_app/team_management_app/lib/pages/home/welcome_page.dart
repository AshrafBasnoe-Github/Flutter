import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

/// Welkomstpagina die wordt weergegeven wanneer de gebruiker de app opent.
class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Welkom'), // Aangepaste appbalk
      backgroundColor: const Color(0xFF1A1A1A), // Donkere achtergrondkleur
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centreer de inhoud
          children: [
            // Hero-widget voor een vloeiende overgang van het logo
            Hero(
              tag: 'appLogo', // Tag voor de animatie
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A), // Donkere cirkelachtergrond
                  shape: BoxShape.circle, // Cirkelvorm
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Schaduwkleur
                      blurRadius: 8, // Hoe wazig de schaduw is
                      offset: const Offset(0, 4), // Positie van de schaduw
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20), // Ruimte rondom het pictogram
                child: const Icon(
                  Icons.group, // Pictogram voor teammanagement
                  size: 120, // Grootte van het pictogram
                  color: Colors.cyan, // Kleur van het pictogram
                ),
              ),
            ),
            const SizedBox(height: 30), // Ruimte tussen logo en tekst
            // Welkomsttekst
            const Text(
              'Welkom bij de\nTeam Management App!',
              style: TextStyle(
                fontSize: 24, // Tekengrootte
                fontWeight: FontWeight.bold, // Vetgedrukte tekst
                color: Colors.white, // Witte tekstkleur
              ),
              textAlign: TextAlign.center, // Centreer de tekst
            ),
            const SizedBox(height: 40), // Ruimte tussen tekst en knoppen
            // Inloggen-knop
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login'); // Navigeer naar de inlogpagina
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan, // Kleur van de knop
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Hoekafronding
                ),
                shadowColor: Colors.black.withOpacity(0.2), // Schaduwkleur
                elevation: 8, // Hoe "verheven" de knop is
              ),
              child: const Text(
                'Inloggen', // Tekst van de knop
                style: TextStyle(
                  fontSize: 18, // Tekengrootte
                  fontWeight: FontWeight.bold, // Vetgedrukte tekst
                  color: Colors.white, // Witte tekstkleur
                ),
              ),
            ),
            const SizedBox(height: 20), // Ruimte tussen de knoppen
            // Registreren-knop
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register'); // Navigeer naar de registratiepagina
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Kleur van de knop
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Hoekafronding
                ),
                shadowColor: Colors.black.withOpacity(0.2), // Schaduwkleur
                elevation: 8, // Hoe "verheven" de knop is
              ),
              child: const Text(
                'Registreren', // Tekst van de knop
                style: TextStyle(
                  fontSize: 18, // Tekengrootte
                  fontWeight: FontWeight.bold, // Vetgedrukte tekst
                  color: Colors.white, // Witte tekstkleur
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
