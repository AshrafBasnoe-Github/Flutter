import 'package:flutter/material.dart';

class TeamProvider with ChangeNotifier {
  // Lijst met teams
  List<String> _teams = [];

  // Getter om toegang te krijgen tot teams
  List<String> get teams => _teams;

  // Methode om een team toe te voegen
  void addTeam(String teamName) {
    _teams.add(teamName);
    notifyListeners(); // Laat widgets weten dat de data is veranderd
  }

  // Methode om een team te verwijderen
  void removeTeam(String teamName) {
    _teams.remove(teamName);
    notifyListeners();
  }
}
