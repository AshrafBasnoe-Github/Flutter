import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TeamInvitesPage extends StatefulWidget {
  @override
  _TeamInvitesPageState createState() => _TeamInvitesPageState();
}

class _TeamInvitesPageState extends State<TeamInvitesPage> {
  List<dynamic> teams = [];
  Map<int, List<dynamic>> invitesByTeam = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeamsAndInvites();
  }

  Future<void> fetchTeamsAndInvites() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Haal teams op
      final fetchedTeams = await ApiService.fetchAllTeams();
      setState(() {
        teams = fetchedTeams;
      });

      // Haal invites op per team
      for (var team in teams) {
        final invites = await ApiService.fetchInvitesForTeam(team['id']);
        setState(() {
          invitesByTeam[team['id']] = invites;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij het ophalen van gegevens: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleInvite(int inviteId, String action) async {
    try {
      await ApiService.updateInviteStatus(inviteId, action);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uitnodiging $action.')),
      );
      fetchTeamsAndInvites(); // Ververs de gegevens
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij het $action van de uitnodiging: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mijn Team Invites'),
        backgroundColor: Colors.cyan,
      ),
      backgroundColor: const Color(0xFF121212),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
          : ListView.builder(
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                final invites = invitesByTeam[team['id']] ?? [];
                return ExpansionTile(
                  title: Text(
                    team['name'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  children: invites.isEmpty
                      ? [
                          const ListTile(
                            title: Text(
                              'Geen uitnodigingen beschikbaar.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        ]
                      : invites.map((invite) {
                          return ListTile(
                            title: Text(
                              'Match ID: ${invite['matchId']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Status: ${invite['status']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      handleInvite(invite['id'], 'accepted'),
                                  child: const Text(
                                    'Accepteer',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      handleInvite(invite['id'], 'declined'),
                                  child: const Text(
                                    'Weiger',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                );
              },
            ),
    );
  }
}
