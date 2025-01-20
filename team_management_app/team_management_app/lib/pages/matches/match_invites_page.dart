import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/invite_card.dart';

class MatchInvitesPage extends StatefulWidget {
  @override
  _MatchInvitesPageState createState() => _MatchInvitesPageState();
}

class _MatchInvitesPageState extends State<MatchInvitesPage> {
  List<dynamic> invites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInvites();
  }

  Future<void> fetchInvites() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedInvites = await ApiService.getInvites();
      setState(() {
        invites = fetchedInvites;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fout bij het ophalen van uitnodigingen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _acceptInvite(int inviteId) async {
    try {
      await ApiService.updateInviteStatus(inviteId, 'accepted');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uitnodiging geaccepteerd')),
      );
      fetchInvites(); // Refresh de lijst
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fout bij het accepteren van uitnodiging: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _declineInvite(int inviteId) async {
    try {
      await ApiService.updateInviteStatus(inviteId, 'declined');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uitnodiging geweigerd')),
      );
      fetchInvites(); // Refresh de lijst
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fout bij het weigeren van uitnodiging: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mijn Team Uitnodigingen'),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyan),
            )

          : invites.isEmpty
              ? const Center(
                  child: Text(
                    'Geen uitnodigingen beschikbaar.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: invites.length,
                  itemBuilder: (context, index) {
                    final invite = invites[index];
                    return InviteCard(
                      invite: invite,
                      onAccept: () => _acceptInvite(invite['id']),
                      onDecline: () => _declineInvite(invite['id']),
                    );
                  },
                ),
    );
  }
}
