import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_management_app/services/api_service.dart';

class EditEventPage extends StatefulWidget {
  final Map<String, dynamic> event; // Het evenement dat wordt bewerkt
  final VoidCallback onUpdate; // Callback om de parent-widget te informeren over updates

  const EditEventPage({Key? key, required this.event, required this.onUpdate}) : super(key: key);

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>(); // Sleutel voor het formulier
  late TextEditingController _titleController; // Controller voor titel
  late TextEditingController _descriptionController; // Controller voor beschrijving
  late TextEditingController _instructionsController; // Controller voor instructies
  late DateTime _startDateTime; // Startdatum en tijd
  late DateTime _endDateTime; // Einddatum en tijd

  @override
  void initState() {
    super.initState();
    // Initialiseer de controllers met bestaande waarden van het evenement
    _titleController = TextEditingController(text: widget.event['title']);
    _descriptionController = TextEditingController(text: widget.event['description']);
    _instructionsController =
        TextEditingController(text: widget.event['metadata']['instructions']);
    _startDateTime = DateTime.parse(widget.event['datetimeStart']); // Parseer startdatum
    _endDateTime = DateTime.parse(widget.event['datetimeEnd']); // Parseer einddatum
  }

  // Functie om het evenement te updaten
  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return; // Valideer het formulier

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Haal de token op

    if (token == null) {
      // Toon fout als de token niet beschikbaar is
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geen token beschikbaar. Log in opnieuw.')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      return;
    }

    try {
      // Roep de API aan om het evenement bij te werken
      final success = await ApiService.updateEvent(
        id: widget.event['id'],
        title: _titleController.text,
        description: _descriptionController.text,
        datetimeStart: _startDateTime.toIso8601String(),
        datetimeEnd: _endDateTime.toIso8601String(),
        instructions: _instructionsController.text,
      );

      if (success) {
        // Als de update succesvol is, toon een melding en informeer de parent-widget
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evenement succesvol bijgewerkt!')),
        );
        widget.onUpdate(); // Roep de update callback aan
        Navigator.pop(context, true); // Navigeer terug met succesresultaat
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fout bij het bijwerken van evenement.')),
        );
      }
    } catch (e) {
      // Toon een foutmelding bij een uitzondering
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout: $e')),
      );
    }
  }

  // Functie om datum en tijd te selecteren
  Future<void> _pickDateTime({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDateTime : _endDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startDateTime : _endDateTime),
    );

    if (time == null) return;

    setState(() {
      // Werk de start- of einddatum bij
      if (isStart) {
        _startDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      } else {
        _endDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bewerk Evenement'),
        backgroundColor: const Color(0xFF1A1A1A), // Donkere achtergrondkleur
      ),
      backgroundColor: const Color(0xFF1A1A1A), // Donkere achtergrondkleur voor body
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Koppel het formulier aan de sleutel
          child: ListView(
            children: [
              // Titel veld
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyan),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value == null || value.isEmpty ? 'Vereist' : null,
              ),
              const SizedBox(height: 16),
              // Beschrijving veld
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Beschrijving',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyan),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Vereist' : null,
              ),
              const SizedBox(height: 16),
              // Startdatum en tijd
              ListTile(
                title: const Text(
                  'Startdatum en tijd',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${_startDateTime.toLocal()}'.split('.')[0],
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: const Icon(Icons.calendar_today, color: Colors.cyan),
                onTap: () => _pickDateTime(isStart: true),
              ),
              const SizedBox(height: 16),
              // Einddatum en tijd
              ListTile(
                title: const Text(
                  'Einddatum en tijd',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${_endDateTime.toLocal()}'.split('.')[0],
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: const Icon(Icons.calendar_today, color: Colors.cyan),
                onTap: () => _pickDateTime(isStart: false),
              ),
              const SizedBox(height: 16),
              // Instructies veld
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructies (optioneel)',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyan),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              // Bijwerken knop
              Center(
                child: ElevatedButton(
                  onPressed: _updateEvent, // Roep de update-functie aan
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Evenement Bijwerken',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
