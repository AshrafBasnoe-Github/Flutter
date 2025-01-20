import 'package:flutter/material.dart';
import 'pages/home/welcome_page.dart';
import 'pages/login/login_page.dart';
import 'pages/login/register_page.dart';
import 'pages/home/home_page.dart';
import 'pages/team/team_page.dart';
import 'pages/team/add_team_page.dart';
import 'pages/team/team_details_page.dart';
import 'pages/event/create_event_page.dart';
import 'pages/qrcode/qr_generator_page.dart';
import 'pages/team/all_teams_page.dart';
import 'pages/event/all_events_page.dart';
import 'pages/event/events_details_page.dart';
import 'pages/event/edit_event_page.dart';
import 'pages/matches/all_matches_page.dart';
import 'pages/matches/match_details_page.dart';
import 'pages/matches/create_match_page.dart';
import 'pages/matches/edit_match_page.dart';
import 'pages/matches/match_invites_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.cyan,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => LoggedInHomePage(),
        '/teams': (context) => TeamsPage(),
        '/add-team': (context) => AddTeamPage(),
        '/create-event': (context) => CreateEventPage(),
        '/all-teams': (context) => AllTeamsPage(),
        '/all-events': (context) => AllEventsPage(),
        '/all-matches': (context) => AllMatchesPage(),
        '/create-match': (context) => CreateMatchPage(),
        '/match-invites': (context) => MatchInvitesPage(),
        '/team-invites': (context) => MatchInvitesPage(),
        '/qr-generator': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return QRGeneratorPage(teamId: args['teamId']);
        },
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/team-details':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args == null || !args.containsKey('team')) {
              return _errorPage();
            }
            return MaterialPageRoute(
              builder: (context) => TeamDetailsPage(
                team: args['team'],
              ),
            );
          case '/event-details':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args == null ||
                !args.containsKey('event') ||
                !args.containsKey('onDelete') ||
                !args.containsKey('onUpdate')) {
              return _errorPage();
            }
            return MaterialPageRoute(
              builder: (context) => EventDetailsPage(
                event: args['event'],
                onDelete: args['onDelete'],
                onUpdate: args['onUpdate'],
              ),
            );
          case '/edit-event':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args == null || !args.containsKey('event')) {
              return _errorPage();
            }
            return MaterialPageRoute(
              builder: (context) => EditEventPage(
                event: args['event'],
                onUpdate: args['onUpdate'],
              ),
            );
          case '/match-details':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args == null || !args.containsKey('matchId')) {
              return _errorPage();
            }
            return MaterialPageRoute(
              builder: (context) => MatchDetailsPage(
                matchId: args['matchId'],
              ),
            );
          case '/edit-match':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args == null || !args.containsKey('matchDetails')) {
              return _errorPage();
            }
            return MaterialPageRoute(
              builder: (context) => EditMatchPage(
                matchDetails: args['matchDetails'],
              ),
            );
          default:
            return _errorPage();
        }
      },
    );
  }

  MaterialPageRoute _errorPage() {
    return MaterialPageRoute(
      builder: (context) => const Scaffold(
        body: Center(
          child: Text(
            'Pagina niet gevonden of ongeldige argumenten.',
            style: TextStyle(fontSize: 20, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
