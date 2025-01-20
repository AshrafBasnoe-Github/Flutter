import 'package:flutter/material.dart';
import '../../services/api_service.dart'; // Voor het ophalen van data
import 'match_details_page.dart'; // Voor de detailpagina van een match
import 'create_match_page.dart'; // Voor de pagina om een match aan te maken
import '../../widgets/match_card.dart'; // Voor een visueel aantrekkelijke matchkaart

/// De hoofdpagina die alle beschikbare matches weergeeft.
class AllMatchesPage extends StatefulWidget {
  @override
  _AllMatchesPageState createState() => _AllMatchesPageState();
}

class _AllMatchesPageState extends State<AllMatchesPage> {
  List<dynamic> matches = []; // Lijst om alle matches op te slaan
  bool isLoading = false; // Indicator voor het laden van data

  @override
  void initState() {
    super.initState();
    fetchMatches(); // Haal de matches op wanneer de pagina wordt geladen
  }

  /// Haal alle beschikbare matches op via de API.
  Future<void> fetchMatches() async {
    setState(() {
      isLoading = true; // Zet de laadindicator aan
    });

    try {
      final fetchedMatches = await ApiService.getAllMatches(); // API-aanroep
      setState(() {
        matches = fetchedMatches; // Bewaar de opgehaalde matches in de lijst
      });
    } catch (e) {
      // Toon een foutmelding bij een fout tijdens het ophalen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching matches: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Zet de laadindicator uit
      });
    }
  }

  /// Navigeer naar de pagina om een nieuwe match aan te maken.
  void _navigateToCreateMatch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateMatchPage()), // Navigeer naar de aanmaakpagina
    );

    // Als een match is aangemaakt, vernieuw de lijst
    if (result == true) {
      fetchMatches();
    }
  }

  /// Behandel het klikken op een match.
  /// Controleer of de gebruiker toegang heeft tot de details.
  void _handleMatchTap(BuildContext context, dynamic match) async {
    final currentUserId = await ApiService.getCurrentUserId(); // Haal de ID van de huidige gebruiker op

    if (match['isTeamMember'] == true || match['createdBy'].toString() == currentUserId) {
      // Als de gebruiker toegang heeft, navigeer naar de detailpagina
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatchDetailsPage(matchId: match['id']),
        ),
      );
    } else {
      // Toon een pop-up als de gebruiker geen toegang heeft
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Geen Toegang'),
            content: const Text(
              'Je bent niet uitgenodigd bij deze match en hebt geen toegang tot de details.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Sluit de pop-up
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Matches'), // Titel van de pagina
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // Knop om een nieuwe match aan te maken
            tooltip: 'Create Match',
            onPressed: _navigateToCreateMatch,
          ),
        ],
        backgroundColor: const Color(0xFF1A1A1A), // Donkere achtergrondkleur
      ),
      backgroundColor: const Color(0xFF1A1A1A), // Donkere achtergrondkleur voor de hele pagina
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyan), // Toon een laadindicator
            )
          : matches.isEmpty
              ? const Center(
                  child: Text(
                    'No matches available.', // Toon een bericht als er geen matches zijn
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchMatches, // Voeg pull-to-refresh functionaliteit toe
                  child: ListView.builder(
                    itemCount: matches.length, // Aantal matches in de lijst
                    itemBuilder: (context, index) {
                      final match = matches[index]; // Haal een match op uit de lijst
                      return MatchCard(
                        match: match, // Geef de match door aan de kaart
                        onTap: () => _handleMatchTap(context, match), // Behandel het klikken op de kaart
                      );
                    },
                  ),
                ),
    );
  }
}
