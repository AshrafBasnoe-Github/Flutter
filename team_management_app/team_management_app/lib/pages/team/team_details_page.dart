import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class TeamDetailsPage extends StatefulWidget {
  final Map<String, dynamic> team;

  const TeamDetailsPage({Key? key, required this.team}) : super(key: key);

  @override
  _TeamDetailsPageState createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {
  String? userId;
  bool isAdmin = false;
  TextEditingController userIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initTokenAndUser();
  }

  Future<void> initTokenAndUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });

    if (userId == widget.team['ownerId'].toString()) {
      setState(() {
        isAdmin = true;
      });
    }
  }

  Future<void> addUserById(String userIdToAdd) async {
    try {
      final success = await ApiService.addUserToTeam(widget.team['id'].toString(), userIdToAdd);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gebruiker succesvol toegevoegd!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fout bij toevoegen gebruiker!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Onverwachte fout: $e')),
      );
    }
  }

  Future<void> removeUserById(String userIdToRemove) async {
    try {
      final success = await ApiService.removeUserFromTeamByAdmin(
        widget.team['id'].toString(),
        userIdToRemove,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gebruiker succesvol verwijderd!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fout bij verwijderen gebruiker!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Onverwachte fout: $e')),
      );
    }
  }

  Widget buildAdminActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Beheeracties:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyan),
        ),
        const SizedBox(height: 16),
        const Text(
          'Voeg een gebruiker toe of verwijder een gebruiker met ID:',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: userIdController,
                decoration: InputDecoration(
                  labelText: 'Gebruiker ID',
                  labelStyle: const TextStyle(color: Colors.cyan),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.cyan, width: 2),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                final userId = userIdController.text.trim();
                if (userId.isNotEmpty) {
                  await addUserById(userId);
                  userIdController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Voer een geldige gebruiker ID in.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text(
                'Toevoegen',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                final userId = userIdController.text.trim();
                if (userId.isNotEmpty) {
                  await removeUserById(userId);
                  userIdController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Voer een geldige gebruiker ID in.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text(
                'Verwijderen',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team['name'] ?? 'Team Details'),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Team Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.cyan),
            ),
            const SizedBox(height: 16),
            Text(
              'Naam: ${widget.team['name'] ?? 'Onbekend'}',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Beschrijving: ${widget.team['description'] ?? 'Geen beschrijving beschikbaar'}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (isAdmin) buildAdminActions(),
          ],
        ),
      ),
    );
  }
}
