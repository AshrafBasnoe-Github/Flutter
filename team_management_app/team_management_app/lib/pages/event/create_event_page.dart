import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Voor datumformattering
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import '../../widgets/custom_app_bar.dart' as CustomAppBar;
import '../../services/api_service.dart';

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  // Controllers voor het beheren van tekstvelden
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();
  final TextEditingController teamIdController = TextEditingController();

  DateTime? startDateTime; // Variabele voor de startdatum en tijd
  DateTime? endDateTime; // Variabele voor de einddatum en tijd
  LatLng? selectedLocation; // Locatiecoördinaten
  bool isLoading = false; // Status voor laadindicator

  // Methode om datum en tijd te selecteren
  Future<void> pickDateTime({
    required BuildContext context,
    required bool isStart,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final pickedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      if (isStart) {
        startDateTime = pickedDateTime;
      } else {
        endDateTime = pickedDateTime;
      }
    });
  }

  // Methode om adres om te zetten naar coördinaten
  Future<void> convertAddressToCoordinates() async {
    if (addressController.text.isEmpty || houseNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vul een geldig adres en huisnummer in.')),
      );
      return;
    }

    final address = '${addressController.text} ${houseNumberController.text}';
    final apiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE'; // Vervang met jouw API-sleutel

    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey');
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        final location = data['results'][0]['geometry']['location'];
        setState(() {
          selectedLocation = LatLng(location['lat'], location['lng']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coördinaten opgehaald: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Geen locatie gevonden: ${data['status']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij ophalen coördinaten: $e')),
      );
    }
  }

  // Methode om het evenement aan te maken
  Future<void> createEvent() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        startDateTime == null ||
        endDateTime == null ||
        teamIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vul alle verplichte velden in.')),
      );
      return;
    }

    setState(() {
      isLoading = true; // Start laadindicator
    });

    try {
      final success = await ApiService.createEvent(
        title: titleController.text,
        description: descriptionController.text,
        datetimeStart: startDateTime!.toIso8601String(),
        datetimeEnd: endDateTime!.toIso8601String(),
        latitude: selectedLocation?.latitude ?? 0.0,
        longitude: selectedLocation?.longitude ?? 0.0,
        teamId: int.parse(teamIdController.text),
        instructions: instructionsController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evenement succesvol aangemaakt!')),
        );
        Navigator.pop(context); // Terug naar de vorige pagina
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fout bij het aanmaken van evenement.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop laadindicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar.CustomAppBar(title: 'Maak Evenement'),
      backgroundColor: const Color(0xFF1A1A1A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voeg een nieuw evenement toe:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
              ),
            ),
            const SizedBox(height: 16),
            // Titelveld
            _buildTextField(
              controller: titleController,
              label: 'Evenementnaam',
            ),
            const SizedBox(height: 16),
            // Beschrijvingsveld
            _buildTextField(
              controller: descriptionController,
              label: 'Beschrijving',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Startdatum en tijd
            _buildDatePickerTile(
              label: 'Startdatum en tijd',
              dateTime: startDateTime,
              onTap: () => pickDateTime(context: context, isStart: true),
            ),
            const SizedBox(height: 16),
            // Einddatum en tijd
            _buildDatePickerTile(
              label: 'Einddatum en tijd',
              dateTime: endDateTime,
              onTap: () => pickDateTime(context: context, isStart: false),
            ),
            const SizedBox(height: 16),
            // Adresveld
            _buildTextField(
              controller: addressController,
              label: 'Adres (optioneel)',
            ),
            const SizedBox(height: 16),
            // Huisnummer
            _buildTextField(
              controller: houseNumberController,
              label: 'Huisnummer (optioneel)',
            ),
            const SizedBox(height: 16),
            // Knop voor coördinaten
            ElevatedButton(
              onPressed: convertAddressToCoordinates,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Haal Coördinaten Op',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            // Weergeven van geselecteerde locatie
            Text(
              selectedLocation == null
                  ? 'Geen locatie geselecteerd.'
                  : 'Latitude: ${selectedLocation!.latitude}, Longitude: ${selectedLocation!.longitude}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            // Team ID
            _buildTextField(
              controller: teamIdController,
              label: 'Team ID',
            ),
            const SizedBox(height: 16),
            // Instructies
            _buildTextField(
              controller: instructionsController,
              label: 'Instructies (optioneel)',
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            // Knop om evenement aan te maken
            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : createEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Evenement Aanmaken',
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
    );
  }

  // Helpermethode voor tekstvelden
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.cyan),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyan, width: 2),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  // Helpermethode voor datum en tijd
  Widget _buildDatePickerTile({
    required String label,
    required DateTime? dateTime,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(color: Colors.cyan),
      ),
      subtitle: Text(
        dateTime == null ? 'Geen datum geselecteerd' : DateFormat.yMd().add_jm().format(dateTime),
        style: const TextStyle(color: Colors.white),
      ),
      trailing: const Icon(Icons.calendar_today, color: Colors.cyan),
      onTap: onTap,
    );
  }
}
