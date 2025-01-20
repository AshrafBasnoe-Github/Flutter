import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class EditMatchPage extends StatefulWidget {
  final Map<String, dynamic> matchDetails;

  const EditMatchPage({Key? key, required this.matchDetails}) : super(key: key);


  @override
  _EditMatchPageState createState() => _EditMatchPageState();
}

class _EditMatchPageState extends State<EditMatchPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  DateTime? datetimeStart;
  DateTime? datetimeEnd;
  late Map<String, dynamic> location;


  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.matchDetails['title']);
    descriptionController =
        TextEditingController(text: widget.matchDetails['description']);
    datetimeStart = DateTime.parse(widget.matchDetails['datetimeStart']);
    datetimeEnd = DateTime.parse(widget.matchDetails['datetimeEnd']);
    location = widget.matchDetails['location'];
  }

  Future<void> pickDateTime({
    required BuildContext context,
    required bool isStart,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? datetimeStart! : datetimeEnd!,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          isStart ? datetimeStart! : datetimeEnd!),
    );

    if (time == null) return;

    setState(() {
      final pickedDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isStart) {
        datetimeStart = pickedDateTime;
      } else {
        datetimeEnd = pickedDateTime;
      }
    });
  }

  Future<void> updateMatch() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await ApiService.updateMatch(
        matchId: widget.matchDetails['id'],
        title: titleController.text,
        description: descriptionController.text,
        datetimeStart: datetimeStart!.toIso8601String(),
        datetimeEnd: datetimeEnd!.toIso8601String(),
        location: location,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match successfully updated!')),
        );
        Navigator.pop(context, true); // Return to the previous page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update match.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Match'),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: titleController,
                label: 'Title',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: descriptionController,
                label: 'Description',
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              _buildDatePickerTile(
                label: 'Start Date and Time',
                dateTime: datetimeStart,
                onTap: () => pickDateTime(context: context, isStart: true),
              ),
              const SizedBox(height: 16),
              _buildDatePickerTile(
                label: 'End Date and Time',
                dateTime: datetimeEnd,
                onTap: () => pickDateTime(context: context, isStart: false),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: updateMatch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Update Match',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
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
      validator: validator,
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
        dateTime == null
            ? 'No date selected'
            : DateFormat.yMd().add_jm().format(dateTime),
        style: const TextStyle(color: Colors.white),
      ),
      trailing: const Icon(Icons.calendar_today, color: Colors.cyan),
      onTap: onTap,
    );
  }
}
