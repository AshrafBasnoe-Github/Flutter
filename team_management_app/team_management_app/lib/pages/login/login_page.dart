import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_app_bar.dart';

/// Loginpagina voor de Team Management App.
class LoginPage extends StatelessWidget {
  // Controllers voor het invoeren van gebruikersnaam en wachtwoord
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Functie om de gebruiker in te loggen
  Future<void> login(BuildContext context) async {
    final username = _usernameController.text; // Haal de ingevoerde gebruikersnaam op
    final password = _passwordController.text; // Haal het ingevoerde wachtwoord op

    // Controleer of beide velden zijn ingevuld
    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        // Verstuur een POST-verzoek naar de login-API
        final response = await http.post(
          Uri.parse('https://team-management-api.dops.tech/api/v2/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': username, 'password': password}),
        );

        // Controleer of de login succesvol is
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // Haal de token en gebruiker-ID op
          final token = data['data']['token'];
          final userId = data['data']['id'];

          // Sla de token en gebruiker-ID op in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', data['data']['name']);
          await prefs.setString('token', token);
          await prefs.setString('userId', userId.toString());

          print('Access Token: $token'); // Debug: Print de token
          print('User ID: $userId'); // Debug: Print de gebruiker-ID

          // Navigeer naar de homepagina
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else {
          // Toon een foutmelding als de login mislukt
          final error = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login mislukt: ${error['error'][0]}')),
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
      appBar: const CustomAppBar(title: 'Inloggen'), // Aangepaste appbalk
      backgroundColor: const Color(0xFF1A1A1A), // Donkere achtergrondkleur
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0), // Padding rondom de inhoud
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centreer de inhoud
            crossAxisAlignment: CrossAxisAlignment.start, // Tekst uitlijnen aan de linkerkant
            children: [
              // Welkomsttekst
              const Text(
                'Welkom Terug!',
                style: TextStyle(
                  fontSize: 28, // Tekengrootte
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
              // Inloggen-knop
              Center(
                child: ElevatedButton(
                  onPressed: () => login(context), // Roep de login-functie aan
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
                    'Inloggen',
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
