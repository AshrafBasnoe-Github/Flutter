import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/custom_app_bar.dart';

/// Pagina voor het registreren van een nieuwe gebruiker.
class RegisterPage extends StatelessWidget {
  // Controllers voor gebruikersinvoer
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Functie om een nieuw account aan te maken
  Future<void> register(BuildContext context) async {
    final username = _usernameController.text; // Haal de gebruikersnaam op
    final password = _passwordController.text; // Haal het wachtwoord op

    // Controleer of beide velden zijn ingevuld
    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        // Verstuur een POST-verzoek naar de registratie-API
        final response = await http.post(
          Uri.parse('https://team-management-api.dops.tech/api/v2/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': username, 'password': password}),
        );

        // Controleer of de registratie succesvol was
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account succesvol aangemaakt! Log nu in.')),
          );
          // Navigeer naar de inlogpagina
          Navigator.pushNamed(context, '/login');
        } else {
          // Toon een foutmelding bij mislukking
          final error = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registratie mislukt: ${error['error'][0]}')),
          );
        }
      } catch (e) {
        // Toon een foutmelding bij een netwerkfout
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Netwerkfout: $e')),
        );
      }
    } else {
      // Toon een melding als niet alle velden zijn ingevuld
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vul alle velden in.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Registreren'), // Aangepaste appbalk
      backgroundColor: const Color(0xFF1A1A1A), // Donkere achtergrondkleur
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0), // Padding rondom de inhoud
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centreer de inhoud
            crossAxisAlignment: CrossAxisAlignment.start, // Tekst uitlijnen aan de linkerkant
            children: [
              // Titel van de registratiepagina
              const Text(
                'Maak een nieuw account aan:',
                style: TextStyle(
                  fontSize: 22, // Tekengrootte
                  fontWeight: FontWeight.bold, // Vetgedrukte tekst
                  color: Colors.cyan, // Tekstkleur
                ),
              ),
              const SizedBox(height: 20), // Ruimte tussen tekst en tekstveld
              // Tekstveld voor gebruikersnaam
              _buildTextField(
                controller: _usernameController,
                label: 'Gebruikersnaam',
              ),
              const SizedBox(height: 16), // Ruimte tussen tekstvelden
              // Tekstveld voor wachtwoord
              _buildTextField(
                controller: _passwordController,
                label: 'Wachtwoord',
                obscureText: true, // Verberg het wachtwoord
              ),
              const SizedBox(height: 24), // Ruimte tussen tekstveld en knop
              // Registreren-knop
              Center(
                child: ElevatedButton(
                  onPressed: () => register(context), // Roep de registratie-functie aan
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
                    'Registreren',
                    style: TextStyle(
                      fontSize: 18, // Tekengrootte
                      fontWeight: FontWeight.bold, // Vetgedrukte tekst
                      color: Colors.white, // Witte tekstkleur
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hulpmethode om een tekstveld te bouwen.
  Widget _buildTextField({
    required TextEditingController controller, // Controller voor het veld
    required String label, // Labeltekst
    bool obscureText = false, // Verberg tekst (voor wachtwoorden)
  }) {
    return TextField(
      controller: controller, // Koppel de controller
      obscureText: obscureText, // Stel in of de tekst verborgen moet zijn
      decoration: InputDecoration(
        labelText: label, // Tekst voor het label
        labelStyle: const TextStyle(color: Colors.cyan), // Kleur van het label
        filled: true, // Vul het veld met een achtergrondkleur
        fillColor: const Color(0xFF2A2A2A), // Achtergrondkleur van het tekstveld
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Hoekafronding
          borderSide: BorderSide.none, // Geen rand
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Hoekafronding
          borderSide: const BorderSide(color: Colors.cyan, width: 2), // Rand bij focus
        ),
      ),
      style: const TextStyle(color: Colors.white), // Tekstkleur
    );
  }
}
