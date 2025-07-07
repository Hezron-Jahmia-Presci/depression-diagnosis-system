import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/personnel_types_service.dart';
import '../../../../widget/widget_exporter.dart';

class AdminEditPersonelTypesScreen extends StatefulWidget {
  final int personnelTypeID;
  final VoidCallback onBack;

  const AdminEditPersonelTypesScreen({
    super.key,
    required this.personnelTypeID,
    required this.onBack,
  });

  @override
  State<AdminEditPersonelTypesScreen> createState() =>
      _AdminEditPersonelTypesScreenState();
}

class _AdminEditPersonelTypesScreenState
    extends State<AdminEditPersonelTypesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _personnelTypeService = PersonnelTypeService();
  final _nameController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadPersonnelType();
  }

  Future<void> _loadPersonnelType() async {
    try {
      final type = await _personnelTypeService.getPersonnelTypeById(
        widget.personnelTypeID,
      );
      if (type != null && type['name'] != null) {
        _nameController.text = type['name'];
        setState(() => _isLoading = false);
      } else {
        _setError();
      }
    } catch (_) {
      _setError();
    }
  }

  void _setError() {
    setState(() {
      _hasError = true;
      _isLoading = false;
    });
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final updatedData = {'name': _nameController.text.trim()};

    final result = await _personnelTypeService.createPersonnelType(updatedData);

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result != null && result['error'] == null) {
      ReusableSnackbarWidget.show(context, 'Personnel type updated!');
      widget.onBack(); // navigate back
    } else {
      ReusableSnackbarWidget.show(context, result?['error'] ?? 'Update failed');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return const Center(child: Text('Failed to load personnel type.'));
    }

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: widget.onBack,
              ),
              const Text(
                'Edit Personnel Type',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),

          const SizedBox(height: 24),

          ReusableTextFieldWidget(
            controller: _nameController,
            label: 'Personnel Type Name',
            validator:
                (val) => val == null || val.isEmpty ? 'Name is required' : null,
            autofillHints: [],
          ),
          const SizedBox(height: 28),
          ReusableButtonWidget(
            text: 'Save Changes',
            isLoading: _isSubmitting,
            onPressed: _submitUpdate,
          ),
        ],
      ),
    );
  }
}
