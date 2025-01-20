import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/api_service.dart';
import 'edit_match_page.dart';

class MatchDetailsPage extends StatefulWidget {
  final int matchId;

  const MatchDetailsPage({Key? key, required this.matchId}) : super(key: key);

  @override
  _MatchDetailsPageState createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  Map<String, dynamic>? matchDetails;
  String? address;
  List<dynamic> userTeams = [];
  int? selectedTeamId;

  String? qrCodeData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMatchDetails();
    fetchUserTeams();
    generateQrCode();
  }

  Future<void> fetchMatchDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final details = await ApiService.getMatchDetails(widget.matchId);
      setState(() {
        matchDetails = details;
      });

      if (details != null && details['location'] != null) {
        final fetchedAddress = await ApiService.getAddressFromCoordinates(
          details['location']['latitude'],
          details['location']['longitude'],
        );
        setState(() {
          address = fetchedAddress;
        });
      } else {
        setState(() {
          address = 'Locatie niet beschikbaar';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij het ophalen van wedstrijdgegevens: $e')),

      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserTeams() async {
    try {
      final teams = await ApiService.fetchAllTeams();
      setState(() {
        userTeams = teams;
        if (userTeams.isNotEmpty) {
          selectedTeamId = userTeams.first['id'];
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij het ophalen van teams: $e')),
      );
    }
  }

  void generateQrCode() {
    setState(() {
      qrCodeData = 'https://team-management-api.dops.tech/api/v2/matches/${widget.matchId}/join';

    });
  }

  Future<void> sendInvite() async {
    if (selectedTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecteer een team om uit te nodigen.')),

      );
      return;
    }

    try {
      final success = await ApiService.sendInvite(widget.matchId, selectedTeamId!);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uitnodiging succesvol verzonden.')),
        );
        fetchMatchDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fout bij het verzenden van uitnodiging.')),

        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij het verzenden van uitnodiging: $e')),
      );
    }
  }

  Future<void> deleteMatch() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bevestiging'),
          content: const Text('Weet je zeker dat je deze wedstrijd wilt verwijderen?'),

          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuleren'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ApiService.deleteMatch(widget.matchId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wedstrijd succesvol verwijderd.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fout bij het verwijderen van de wedstrijd: $e')),

      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(matchDetails?['title'] ?? 'Wedstrijd Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Bewerk Wedstrijd',
            onPressed: () {
              if (matchDetails == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMatchPage(matchDetails: matchDetails!),

                ),
              ).then((_) => fetchMatchDetails());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Verwijder Wedstrijd',
            onPressed: deleteMatch,
          ),
        ],
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyan),
            )
          : matchDetails == null
              ? const Center(
                  child: Text(
                    'Geen wedstrijdgegevens beschikbaar.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Titel', matchDetails!['title']),
                      const SizedBox(height: 12),
                      _buildDetailRow('Beschrijving', matchDetails!['description']),
                      const SizedBox(height: 12),
                      _buildDetailRow('Startdatum', _formatDate(matchDetails!['datetimeStart'])),
                      const SizedBox(height: 12),
                      _buildDetailRow('Einddatum', _formatDate(matchDetails!['datetimeEnd'])),

                      const SizedBox(height: 12),
                      _buildDetailRow('Locatie', address ?? 'Adres ophalen...'),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.cyan),
                      const Text(
                        'Uitgenodigde Teams',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (matchDetails!['invites'] != null && matchDetails!['invites'].isNotEmpty)

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: matchDetails!['invites'].length,
                          itemBuilder: (context, index) {
                            final invite = matchDetails!['invites'][index];
                            return ListTile(
                              title: Text(
                                invite['team']?['name'] ?? 'Onbenoemd Team',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Status: ${invite['status']}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            );
                          },
                        )
                      else
                        const Text(
                          'Geen uitnodigingen beschikbaar.',
                          style: TextStyle(color: Colors.white),
                        ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nodig een team uit',

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (userTeams.isNotEmpty)
                        DropdownButton<int>(
                          value: selectedTeamId,

                          items: userTeams.map((team) {
                            return DropdownMenuItem<int>(
                              value: team['id'],
                              child: Text(
                                team['name'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTeamId = value;

                            });
                          },
                          dropdownColor: const Color(0xFF1A1A1A),
                          style: const TextStyle(color: Colors.white),
                        )
                      else
                        const Text(
                          'Geen teams beschikbaar om uit te nodigen.',
                          style: TextStyle(color: Colors.white),
                        ),
                      const SizedBox(height: 8),

                      ElevatedButton(
                        onPressed: sendInvite,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Uitnodiging Verzenden'),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.cyan),
                      const Text(
                        'QR-Code voor deelname',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                        ),
                      ),
                      const SizedBox(height: 8),
                      qrCodeData != null
                          ? Center(
                              child: QrImageView(
                                data: qrCodeData!,
                                version: QrVersions.auto,
                                size: 200.0,
                                backgroundColor: Colors.white,
                              ),
                            )
                          : const Text('QR-code wordt gegenereerd...'),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.cyan,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value?.toString() ?? 'N.v.t.',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.day}-${parsedDate.month}-${parsedDate.year} ${parsedDate.hour}:${parsedDate.minute}';
    } catch (e) {
      return date;
    }
  }
}
