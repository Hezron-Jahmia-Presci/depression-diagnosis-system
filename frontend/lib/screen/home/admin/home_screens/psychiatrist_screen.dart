import 'package:flutter/material.dart';

import '../../../../service/psychiatrist_service.dart' show PsychiatristService;
import '../../../../widget/widget_exporter.dart' show ReusableCardWidget;
import '../../psychiatrist/psychiatrist_screens/psychiatrist_details_screen.dart'
    show PsychiatristDetailsScreen;

class PsychiatristScreen extends StatefulWidget {
  const PsychiatristScreen({super.key});

  @override
  State<PsychiatristScreen> createState() => _PsychiatristScreenState();
}

class _PsychiatristScreenState extends State<PsychiatristScreen> {
  final PsychiatristService _psychiatristService = PsychiatristService();
  List<Map<String, dynamic>>? _psychiatristDetails;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPsychiatristDetails();
  }

  Future<void> _fetchPsychiatristDetails() async {
    try {
      final details = await _psychiatristService.getAllPsychiatrists();
      if (details != null && details.isNotEmpty) {
        setState(() {
          _psychiatristDetails = List<Map<String, dynamic>>.from(details);
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _hasError
        ? Center(child: Text('Error fetching details'))
        : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 13),
          child:
              _psychiatristDetails != null && _psychiatristDetails!.isNotEmpty
                  ? _buildPsychiatristList()
                  : const Center(child: Text('No psychiatrists available')),
        );
  }

  Widget _buildPsychiatristList() {
    return ListView.builder(
      itemCount: _psychiatristDetails!.length,
      itemBuilder: (context, index) {
        final psych = _psychiatristDetails![index];
        return ReusableCardWidget(
          child: ListTile(
            title: Text(
              "${psych['first_name'] ?? ''} ${psych['last_name'] ?? ''}",
            ),
            subtitle: Text("Email: ${psych['email'] ?? ''}"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              final psychiatristID =
                  psych['ID']; // Correct access of 'ID' from the map
              if (psychiatristID != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PsychiatristDetailsScreen(
                          psychiatristID: psychiatristID,
                        ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
