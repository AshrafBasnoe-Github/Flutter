import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_management_app/services/api_service.dart';
import 'package:team_management_app/widgets/custom_app_bar.dart' as customAppBar;

class AllTeamsPage extends StatefulWidget {
  @override
  _AllTeamsPageState createState() => _AllTeamsPageState();
}

class _AllTeamsPageState extends State<AllTeamsPage> {
  List<dynamic> myTeams = [];
  List<dynamic> otherTeams = [];
  String? token;
  String? userId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAllTeams();
  }

  Future<void> fetchAllTeams() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
      userId = prefs.getString('userId');

      if (token == null || userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geen token beschikbaar. Log in opnieuw.')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      final teams = await ApiService.getAllTeams(token!);
      setState(() {
        myTeams = teams.where((team) => team['ownerId'].toString() == userId).toList();
        otherTeams = teams.where((team) => team['ownerId'].toString() != userId).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij het ophalen van teams: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteTeam(int teamId) async {
    if (token == null) return;

    try {
      final success = await ApiService.deleteTeam(teamId.toString());
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team succesvol verwijderd!')),
        );
        fetchAllTeams();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fout bij het verwijderen van het team.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout: $e')),
      );
    }
  }

  Widget buildTeamList(List<dynamic> teams, bool isOwnerList) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isOwnerList ? 'Mijn Teams' : 'Andere Teams',
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
                  child: Tooltip(
                    message: 'Team ID: ${team['id']}',
                    textStyle: const TextStyle(color: Colors.white),
                    decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      title: Text(
                        team['name'] ?? 'Onbekend Team',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        team['description'] ?? 'Geen beschrijving beschikbaar',
                        style: TextStyle(
                          color: isOwnerList ? Colors.greenAccent : Colors.grey,
                        ),
                      ),
                      trailing: isOwnerList
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Verwijder team',
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text('Team verwijderen'),
                                      content: const Text('Weet je zeker dat je dit team wilt verwijderen?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Annuleren'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            deleteTeam(team['id']);
                                          },
                                          child: const Text('Verwijderen'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const Icon(Icons.arrow_forward_ios, color: Colors.cyan),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamMembersPage(team: team),
                          ),
                        );
                      },
                    ),
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
      appBar: customAppBar.CustomAppBar(title: 'Alle Teams'),
      backgroundColor: const Color(0xFF1A1A1A),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.cyan,
              ),
            )
          : Row(
              children: [
                buildTeamList(myTeams, true),
                const VerticalDivider(width: 1, thickness: 1, color: Colors.grey),
                buildTeamList(otherTeams, false),
              ],
            ),
    );
  }
}

class TeamMembersPage extends StatelessWidget {
  final Map<String, dynamic> team;

  const TeamMembersPage({Key? key, required this.team}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final members = team['members'] ?? [];

    return Scaffold(
      appBar: customAppBar.CustomAppBar(title: 'Teamleden'),
      backgroundColor: const Color(0xFF1A1A1A),
      body: members.isEmpty
          ? const Center(
              child: Text(
                'Geen leden in dit team.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: const Color(0xFF2A2A2A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    title: Text(
                      member['name'] ?? 'Onbekende Gebruiker',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Gebruiker ID: ${member['id']}',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
