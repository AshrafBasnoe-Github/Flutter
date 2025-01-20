import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart'; // Zorg dat ApiService is toegevoegd voor de API-aanroep

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String userId = "Laden...";
  List<String> teamIds = []; // Lijst van team-IDs

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  /// Haalt gebruikersinformatie en team-ID's op
  Future<void> fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final id = prefs.getString('userId');

    setState(() {
      userId = id ?? 'Onbekend';
    });

    if (token != null && userId != "Onbekend") {
      try {
        final teams = await ApiService.getUserTeamsBar(token, userId);
        setState(() {
          // Converteer de opgehaalde teams naar een lijst van IDs
          teamIds = teams.map<String>((team) => team['id'].toString()).toList();
        });
      } catch (e) {
        print('Fout bij het ophalen van teams: $e');
      }
    }
  }

  /// Uitloggen en teruggaan naar de loginpagina
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Verwijder opgeslagen gegevens
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // Navigeer naar login
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.cyan,
        ),
      ),
      backgroundColor: const Color(0xFF1A1A1A), // Donkere achtergrond
      elevation: 4,
      actions: [
        Tooltip(
          message: 'User ID: $userId\nTeam IDs: ${teamIds.isNotEmpty ? teamIds.join(", ") : "Geen teams"}',
          textStyle: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: BoxDecoration(
            color: Colors.cyan,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.info, color: Colors.cyan),
            tooltip: 'Gebruikersinformatie',
            onPressed: () {}, // Geen actie bij klikken
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.cyan),
          tooltip: 'Uitloggen',
          onPressed: () => logout(context), // Uitlogactie
        ),
      ],
    );
  }
}
