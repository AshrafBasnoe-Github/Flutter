import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import '../../widgets/custom_app_bar.dart' as CustomAppBar;
import '../../services/api_service.dart';

class CreateMatchPage extends StatefulWidget {
  @override
  _CreateMatchPageState createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();
  final TextEditingController teamIdController = TextEditingController();
  final TextEditingController inviteTeamIdController = TextEditingController();


  DateTime? startDateTime;
  DateTime? endDateTime;
  LatLng? selectedLocation;
  bool isLoading = false;

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

  Future<void> convertAddressToCoordinates() async {
    if (addressController.text.isEmpty || houseNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid address and house number.')),

      );
      return;
    }

    final address = '${addressController.text} ${houseNumberController.text}';
    const apiKey = 'AIzaSyBcdklvcFikUBq8q2223s8L_PlsAq-pd9E'; // Replace with your actual Google API Key


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
            content: Text(
                'Coordinates fetched: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No location found: ${data['status']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching coordinates: $e')),
      );
    }
  }

  Future<void> createMatch() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        startDateTime == null ||
        endDateTime == null ||
        selectedLocation == null ||
        teamIdController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final success = await ApiService.createMatch({

        'title': titleController.text,
        'description': descriptionController.text,
        'datetimeStart': startDateTime!.toIso8601String(),
        'datetimeEnd': endDateTime!.toIso8601String(),
        'location': {
          'latitude': selectedLocation!.latitude,
          'longitude': selectedLocation!.longitude,
        },
        'teamId': int.parse(teamIdController.text),
        'metadata': {
          'instructions': 'Bring all necessary equipment', // Optional metadata field
        },

      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match created successfully!')),
        );
        Navigator.pop(context, true); // Return to the previous page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error creating match.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar.CustomAppBar(title: 'Create Match'),
      backgroundColor: const Color(0xFF1A1A1A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add a new match:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: titleController,
              label: 'Match Title',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: descriptionController,
              label: 'Description',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildDatePickerTile(
              label: 'Start Date and Time',
              dateTime: startDateTime,
              onTap: () => pickDateTime(context: context, isStart: true),
            ),
            const SizedBox(height: 16),
            _buildDatePickerTile(
              label: 'End Date and Time',
              dateTime: endDateTime,
              onTap: () => pickDateTime(context: context, isStart: false),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: addressController,
              label: 'Address',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: houseNumberController,
              label: 'House Number',
            ),
            const SizedBox(height: 16),
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
                'Fetch Coordinates',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              selectedLocation == null
                  ? 'No location selected.'
                  : 'Latitude: ${selectedLocation!.latitude}, Longitude: ${selectedLocation!.longitude}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: teamIdController,
              label: 'Team ID',
            ),


            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : createMatch,
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
                        'Create Match',
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
        dateTime == null ? 'No date selected' : DateFormat.yMd().add_jm().format(dateTime),

        style: const TextStyle(color: Colors.white),
      ),
      trailing: const Icon(Icons.calendar_today, color: Colors.cyan),
      onTap: onTap,
    );
  }
}
