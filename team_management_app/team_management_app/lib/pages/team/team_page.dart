import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../qrcode/qr_generator_page.dart';
import '../../widgets/custom_app_bar.dart';

class TeamsPage extends StatefulWidget {
  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  List<dynamic> myTeams = [];
  List<dynamic> otherTeams = [];
  String? currentUserId;
  bool isLoading = false;

  Future<void> fetchTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    currentUserId = prefs.getString('userId');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Je bent niet ingelogd. Log opnieuw in.')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://team-management-api.dops.tech/api/v2/teams'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          myTeams = data['data']
              .where((team) => team['ownerId'].toString() == currentUserId)
              .toList();
          otherTeams = data['data']
              .where((team) => team['ownerId'].toString() != currentUserId)
              .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout bij het ophalen van teams: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Netwerkfout: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Widget buildTeamList(List<dynamic> teams, bool isOwnedByUser) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isOwnedByUser ? 'Mijn Teams' : 'Andere Teams',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.cyan,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: const Color(0xFF2A2A2A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      team['name'] ?? 'Onbekend team',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOwnedByUser ? Colors.green : Colors.cyan,
                      ),
                    ),
                    subtitle: Text(
                      team['description'] ?? 'Geen beschrijving beschikbaar',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.qr_code, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRGeneratorPage(teamId: team['id'].toString()),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/team-details',
                        arguments: {'team': team, 'isOwnedByUser': isOwnedByUser},
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Teams'),
      backgroundColor: const Color(0xFF1A1A1A),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.cyan,
              ),
            )
          : Row(
              children: [
                buildTeamList(myTeams, true), // Linkerkolom: Mijn teams
                const VerticalDivider(width: 1, thickness: 1, color: Colors.grey),
                buildTeamList(otherTeams, false), // Rechterkolom: Andere teams
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-team');
        },
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
