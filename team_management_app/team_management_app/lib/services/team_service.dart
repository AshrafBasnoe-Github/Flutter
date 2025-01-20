import 'package:http/http.dart' as http;
import 'dart:convert';

class TeamService {

static Future<String?> fetchTeamDetails(String code) async {

    // Implement the method to fetch team details using the code

    // For now, return a dummy value

    await Future.delayed(Duration(seconds: 1)); // Simulate network delay

    return 'Team details for code: $code';

  }


  static const String baseUrl = 'https://team-management-api.dops.tech/api/v2';

  static Future<List<dynamic>> fetchAllTeams() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teams'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; // Return list of teams
      } else {
        print('Error fetching teams: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception occurred: $e');
      return [];
    }
  }
}
