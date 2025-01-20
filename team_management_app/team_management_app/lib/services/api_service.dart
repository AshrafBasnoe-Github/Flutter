import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://team-management-api.dops.tech/api/v2';

/// Verstuur uitnodiging voor een match naar een team
  static Future<bool> sendInvite(int matchId, int teamId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Geen toegangstoken gevonden.');
    }

    final url = Uri.parse('$baseUrl/matches/$matchId/invites');
    final body = jsonEncode({'teamId': teamId});


    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );


      if (response.statusCode == 201) {
        return true; // Uitnodiging succesvol verstuurd
      } else {
        print('Fout bij het versturen van een uitnodiging: ${response.body}');
        return false; // Versturen mislukt
      }
    } catch (e) {
      throw Exception('Netwerkfout bij het versturen van uitnodiging: $e');

    }
  }

  // Haal alle teams op
  static Future<List<dynamic>> fetchAllTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Geen toegangstoken gevonden.');
    }

    final url = Uri.parse('$baseUrl/teams');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Fout bij het ophalen van teams: ${response.body}');
      }
    } catch (e) {
      throw Exception('Netwerkfout bij het ophalen van teams: $e');
    }
  }

static Future<bool> acceptInvite(int inviteId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    throw Exception('Geen toegangstoken gevonden.');
  }

  final url = Uri.parse('$baseUrl/matches/invites/$inviteId');
  final body = jsonEncode({'status': 'accepted'});

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      print('Uitnodiging succesvol geaccepteerd');
      return true;
    } else {
      print('Fout bij het accepteren van uitnodiging: ${response.body}');
      return false;
    }
  } catch (e) {
    throw Exception('Netwerkfout: $e');
  }
}


static Future<List<dynamic>> fetchInvites() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    throw Exception('Geen toegangstoken gevonden.');
  }

  final url = Uri.parse('$baseUrl/matches/invites');

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Fout bij het ophalen van uitnodigingen: ${response.body}');
    }
  } catch (e) {
    throw Exception('Netwerkfout: $e');
  }
}

Future<void> joinViaQr(BuildContext context, int matchId) async {
  try {
    // Haal alle uitnodigingen op
    final invites = await ApiService.fetchInvites();

    // Zoek de relevante uitnodiging
    final invite = invites.firstWhere(
      (invite) => invite['matchId'] == matchId,
      orElse: () => null,
    );

    if (invite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geen uitnodiging gevonden voor deze wedstrijd.')),
      );
      return;
    }

    // Accepteer de uitnodiging
    final success = await ApiService.joinMatch(invite['id']);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Je bent succesvol toegevoegd aan de wedstrijd.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kon niet deelnemen aan de wedstrijd.')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fout bij deelnemen: $e')),
    );
  }
}



// Laat een gebruiker deelnemen aan een wedstrijd
static Future<bool> joinMatch(int matchId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    throw Exception('Geen toegangstoken gevonden.');
  }

  final url = Uri.parse('$baseUrl/matches/$matchId/join');
  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Fout bij deelnemen: ${response.body}');
      return false;
    }
  } catch (e) {
    throw Exception('Netwerkfout: $e');
  }
}



  //  Haalt alle invites op
  static Future<List<dynamic>> fetchInvitesForTeam(int teamId) async {
    const baseUrl = 'https://team-management-api.dops.tech/api/v2';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Geen toegangstoken gevonden.');
    }

    final url = Uri.parse('$baseUrl/teams/$teamId/invites');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Fout bij het ophalen van invites: ${response.body}');
      }
    } catch (e) {
      throw Exception('Netwerkfout: $e');
    }
  }

  // Update Invite Status
  static Future<void> updateInviteStatus(int inviteId, String status) async {
    const baseUrl = 'https://team-management-api.dops.tech/api/v2';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Geen toegangstoken gevonden.');
    }


    final url = Uri.parse('$baseUrl/matches/invites/$inviteId');
    final body = jsonEncode({'status': status});

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Fout bij het updaten van uitnodiging: ${response.body}');
      }
    } catch (e) {
      throw Exception('Netwerkfout: $e');
    }
  }

  // Create invite for other teams
  static Future<void> createInvite(int matchId, int teamId) async {
    const baseUrl = 'https://team-management-api.dops.tech/api/v2';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Geen toegangstoken gevonden.');
    }

    // Corrigeer de API-endpoint
    final url = Uri.parse('$baseUrl/matches/$matchId/invites');
    final body = jsonEncode({'teamId': teamId});

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode != 201) {
        throw Exception(
            'Fout bij het versturen van een uitnodiging: ${response.body}');
      }
    } catch (e) {
      throw Exception('Netwerkfout: $e');
    }
  }

  // Fetch User Details
  static Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    const apiKey =
        'AIzaSyBcdklvcFikUBq8q2223s8L_PlsAq-pd9E'; // Vervang dit met jouw Google Maps API-sleutel
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      } else {
        throw Exception('Fout bij het ophalen van het adres: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching address: $e');
    }
    return null;
  }

  // Fetch Match Details by ID
  static Future<Map<String, dynamic>> fetchMatchById(int matchId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No access token found.');
    }

    final url = Uri.parse('$baseUrl/matches/$matchId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to fetch match details: ${response.body}');
    }
  }

// Get Match by ID
  static Future<Map<String, dynamic>?> getMatchById(int matchId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Geen token gevonden. Log opnieuw in.');
      return null;
    }

    final url = Uri.parse('$baseUrl/matches/$matchId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        print('Fout bij het ophalen van wedstrijdgegevens: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Fout bij het ophalen van wedstrijdgegevens: $e');
      return null;
    }
  }


  // Haalt wedstrijdgegevens op met ID
  static Future<Map<String, dynamic>?> getMatchDetails(int matchId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Geen toegangstoken gevonden.');
    }

    final url = Uri.parse('$baseUrl/matches/$matchId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      } else {
        throw Exception('Fout bij het ophalen van gegevens: ${response.body}');
      }
    } catch (e) {
      throw Exception('Fout bij het ophalen van wedstrijdgegevens: $e');
    }
  }

// Update Match
  static Future<bool> updateMatch({
    required int matchId,
    required String title,
    required String description,
    required String datetimeStart,
    required String datetimeEnd,
    required Map<String, dynamic> location,
    Map<String, dynamic>? metadata,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Geen token gevonden. Log opnieuw in.');
      return false;
    }

    final url = Uri.parse('$baseUrl/matches/$matchId');
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'datetimeStart': datetimeStart,
          'datetimeEnd': datetimeEnd,
          'location': location,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 200) {
        print('Wedstrijd succesvol bijgewerkt');
        return true;
      } else {
        print('Fout bij het bijwerken van wedstrijd: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Fout bij het bijwerken van wedstrijd: $e');
      return false;
    }
  }

  // Get all matches
  static Future<List<dynamic>> getAllMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Geen token gevonden. Log opnieuw in.');
      return [];
    }

    final url = Uri.parse('$baseUrl/matches');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('Fout bij het ophalen van matches: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Fout bij het ophalen van matches: $e');
      return [];
    }
  }

  // Create Match
  static Future<bool> createMatch(Map<String, dynamic> matchData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Geen token gevonden. Log opnieuw in.');
      return false;
    }

    final url = Uri.parse('$baseUrl/matches');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(matchData),
      );

      if (response.statusCode == 201) {
        print('Match succesvol aangemaakt');
        return true;
      } else {
        print('Fout bij het aanmaken van match: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Fout bij het aanmaken van match: $e');
      return false;
    }
  }

  // Delete Match
  static Future<bool> deleteMatch(int matchId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Geen token gevonden. Log opnieuw in.');
      return false;
    }

    final url = Uri.parse('$baseUrl/matches/$matchId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Match succesvol verwijderd');
        return true;
      } else {
        print('Fout bij het verwijderen van match: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Fout bij het verwijderen van match: $e');
      return false;
    }
  }


  // Update Event
  static Future<bool> updateEvent({
    required int id,
    required String title,
    required String description,
    required String datetimeStart,
    required String datetimeEnd,
    String? instructions,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Geen token gevonden. Log opnieuw in.');
      return false;
    }

    final url = Uri.parse('$baseUrl/events/$id');
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'datetimeStart': datetimeStart,
          'datetimeEnd': datetimeEnd,
          'metadata': {
            'instructions': instructions ?? '',
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Evenement succesvol bijgewerkt');
        return true;
      } else {
        print('Fout bij het bijwerken van evenement: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Fout bij het bijwerken van evenement: $e');
      return false;
    }
  }

  // Fetch Invites
  static Future<List<dynamic>> getInvites() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Geen token gevonden. Log opnieuw in.');
      return [];
    }

    final url = Uri.parse('$baseUrl/matches/invites');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('Fout bij het ophalen van uitnodigingen: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Fout bij het ophalen van uitnodigingen: $e');
      return [];
    }
  }


  /// Verwijdert een evenement
  static Future<bool> deleteEvent(int eventId, String token) async {
    final url = Uri.parse('$baseUrl/events/$eventId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Fout bij het verwijderen van evenement: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Verwijderen van evenement mislukt: $e');
      return false;
    }
  }

  /// Haalt alle evenementen op voor teams waar de gebruiker lid van is
  static Future<List<dynamic>> getAllEvents(String token) async {
    final url = Uri.parse('$baseUrl/events');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Evenementen succesvol opgehaald: ${data["data"]}');
        return data['data'] ?? [];
      } else {
        print('Fout bij het ophalen van evenementen: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Netwerkfout bij het ophalen van evenementen: $e');
      return [];
    }
  }

  /// Haalt alle teams op van een gebruiker
  static Future<List<dynamic>> getUserTeams(String token, String userId) async {
    final url = Uri.parse('$baseUrl/users/$userId/teams');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['teams'] ?? [];
      } else {
        throw Exception('Fout bij het ophalen van teams: ${response.body}');
      }
    } catch (e) {
      throw Exception('Fout bij het ophalen van teams: $e');
    }
  }

  //  Haalt alle teams op
  static Future<List<dynamic>> fetchTeamsFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');

    if (token == null || userId == null) {
      throw Exception('Geen token of userId gevonden.');
    }

    return await getUserTeams(token, userId);
  }


  /// Registreert een nieuwe gebruiker
  static Future<bool> register(
      String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Registratiefout: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Registratie mislukt: $e');
      return false;
    }
  }

  /// Voeg gebruiker toe aan een team met een join-verzoek
  static Future<bool> joinTeam(
      String teamId, String token, String userId) async {
    final url = Uri.parse('$baseUrl/teams/$teamId/join');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'userId': int.parse(userId)}),
      );

      if (response.statusCode == 200) {
        print('Gebruiker succesvol toegevoegd aan team: $teamId');
        return true;
      } else {
        print('Fout bij het joinen van team: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Fout bij het uitvoeren van joinTeam: $e');
      return false;
    }
  }

  /// Logt een gebruiker in en retourneert token en gebruiker info
  static Future<Map<String, dynamic>?> login(
      String name, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', data['token']);
        prefs.setString('userId', data['user']['id'].toString());
        return data;
      } else {
        print('Login fout: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Login mislukt: $e');
      return null;
    }
  }

  /// Haalt de huidige gebruiker-ID op uit SharedPreferences
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  /// Haalt alle teams van een gebruiker op
  static Future<List<dynamic>> getUserTeamsBar(
      String token, String userId) async {
    final url = Uri.parse('$baseUrl/users/$userId/teams');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['teams'] ?? [];
      } else {
        print('Fout bij het ophalen van gebruikers teams: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Gebruikers teams ophalen mislukt: $e');
      return [];
    }
  }

  /// Haalt een lijst van alle teams op
  static Future<List<dynamic>> getAllTeams(String token) async {
    final url = Uri.parse('$baseUrl/teams');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('Fout bij het ophalen van alle teams: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Alle teams ophalen mislukt: $e');
      return [];
    }
  }

  /// Creëer een nieuw evenement
  static Future<bool> createEvent({
    required String title,
    required String description,
    required String datetimeStart,
    required String datetimeEnd,
    required double latitude,
    required double longitude,
    required int teamId,
    String? instructions,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Geen token gevonden');
      return false;
    }

    final url = Uri.parse('$baseUrl/events');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'datetimeStart': datetimeStart,
          'datetimeEnd': datetimeEnd,
          'location': {
            'latitude': latitude,
            'longitude': longitude,
          },
          'teamId': teamId,
          'metadata': {
            'instructions': instructions ?? '',
          },
        }),
      );

      if (response.statusCode == 201) {
        print('Evenement succesvol aangemaakt');
        return true;
      } else {
        print('Fout bij het aanmaken van evenement: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Fout bij het aanmaken van evenement: $e');
      return false;
    }
  }

  /// Voeg een gebruiker toe aan een team
  static Future<bool> addUserToTeam(String teamId, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Geen token gevonden');
      return false;
    }

    final url = Uri.parse('$baseUrl/teams/$teamId/addUser');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'userId': int.parse(userId)}),
      );

      if (response.statusCode == 200) {
        print('Gebruiker succesvol toegevoegd aan team: $teamId');
        return true;
      } else {
        print(
            'Fout bij het toevoegen van gebruiker aan team: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Toevoegen aan team mislukt: $e');
      return false;
    }
  }

  /// Verwijdert een gebruiker uit een team door de beheerder
  static Future<bool> removeUserFromTeamByAdmin(
      String teamId, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Geen token gevonden');
      return false;
    }

    final url = Uri.parse('$baseUrl/teams/$teamId/removeUser');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'userId': int.parse(userId)}),
      );

      if (response.statusCode == 200) {
        print('Gebruiker succesvol verwijderd uit team: $teamId');
        return true;
      } else {
        print('Fout bij het verwijderen van gebruiker: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Verwijderen mislukt: $e');
      return false;
    }
  }

  /// Verwijdert een gebruiker uit een team
  static Future<bool> removeUserFromTeam(String teamId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Geen token gevonden');
      return false;
    }

    final url = Uri.parse('$baseUrl/teams/$teamId/members');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Succesvol verwijderd uit team $teamId');
        return true;
      } else {
        print('Fout bij het verwijderen uit team: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Verwijderen uit team mislukt: $e');
      return false;
    }
  }

  /// Verwijdert een team (alleen voor de eigenaar)
  static Future<bool> deleteTeam(String teamId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Geen token gevonden');
      return false;
    }

    final url = Uri.parse('$baseUrl/teams/$teamId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Team succesvol verwijderd: $teamId');
        return true;
      } else {
        print('Fout bij het verwijderen van het team: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Verwijderen van team mislukt: $e');
      return false;
    }
  }
}

// CustomAppBar implementation
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
  List<String> teamIds = [];

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? 'Onbekend';
      teamIds = prefs.getStringList('teamIds') ?? [];
    });
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 4,
      actions: [
        Tooltip(
          message:
              'User ID: $userId\nTeam IDs: ${teamIds.isNotEmpty ? teamIds.join(", ") : "Geen teams"}',
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
          onPressed: () => logout(context),
        ),
      ],
    );
  }
}