import 'package:flutter/material.dart';

import '../../../../widget/widget_exporter.dart';
import '../../../../service/psychiatrist_service.dart' show PsychiatristService;
import 'edit_psychiatrist_details_screen.dart'
    show EditPsychiatristDetailsScreen;

class PsychiatristDetailsScreen extends StatefulWidget {
  final int psychiatristID;
  const PsychiatristDetailsScreen({super.key, required this.psychiatristID});

  @override
  State<PsychiatristDetailsScreen> createState() =>
      _PsychiatristDetailsScreenState();
}

class _PsychiatristDetailsScreenState extends State<PsychiatristDetailsScreen> {
  final PsychiatristService _psyhiatristService = PsychiatristService();
  Map<String, dynamic>? _psychiatristDetails;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPsychiatristDetails();
  }

  Future<void> _fetchPsychiatristDetails() async {
    try {
      final details = await _psyhiatristService.getPsychiatristDetails();
      if (details != null) {
        setState(() {
          _psychiatristDetails = details;
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

  void _navigateToEditPsychiatristDetailsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditPsychiatristDetailsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PROFILE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _hasError
              ? Center(child: Text('Error fetching details'))
              : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 21,
                  vertical: 13,
                ),
                child:
                    _psychiatristDetails != null
                        ? _buildPsychDetails(_psychiatristDetails!)
                        : const Center(child: Text('No details available')),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToEditPsychiatristDetailsScreen,
        icon: const Icon(Icons.edit_note_outlined),
        label: const Text("Edit Details"),
      ),
    );
  }

  Widget _buildPsychDetails(Map<String, dynamic> psych) {
    return Center(
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width / 2,
        height: MediaQuery.sizeOf(context).height / 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReusableCardWidget(
              child: Text('First Name: ${psych['first_name'] ?? 'N/A'}'),
            ),
            const SizedBox(height: 10),
            ReusableCardWidget(
              child: Text('Last Name: ${psych['last_name'] ?? 'N/A'}'),
            ),
            const SizedBox(height: 10),
            ReusableCardWidget(
              child: Text('Email: ${psych['email'] ?? 'N/A'}'),
            ),
          ],
        ),
      ),
    );
  }
}
