import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/department_service.dart';
import 'package:depression_diagnosis_system/widget/widget_exporter.dart';

class AdminEditDepartmentDetailsScreen extends StatefulWidget {
  final int departmentID;
  final VoidCallback onBack;

  const AdminEditDepartmentDetailsScreen({
    super.key,
    required this.departmentID,
    required this.onBack,
  });

  @override
  State<AdminEditDepartmentDetailsScreen> createState() =>
      _AdminEditDepartmentDetailsScreenState();
}

class _AdminEditDepartmentDetailsScreenState
    extends State<AdminEditDepartmentDetailsScreen> {
  final DepartmentService _departmentService = DepartmentService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDepartmentDetails();
  }

  Future<void> _loadDepartmentDetails() async {
    try {
      final department = await _departmentService.getDepartmentById(
        widget.departmentID,
      );
      if (department != null && !department.containsKey('error')) {
        _nameController.text = department['name'] ?? '';
        _descriptionController.text = department['description'] ?? '';
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

    final result = await _departmentService
        .updateDepartment(widget.departmentID, {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
        });

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result != null && result['error'] == null) {
      ReusableSnackbarWidget.show(context, 'Department updated successfully!');
    } else {
      ReusableSnackbarWidget.show(
        context,
        result?['error'] ?? 'Failed to update department',
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_hasError) {
      return const Center(child: Text('Failed to load department details.'));
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
                'Edit Department',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),

          ReusableTextFieldWidget(
            controller: _nameController,
            label: 'Department Name',
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            autofillHints: [],
          ),
          const SizedBox(height: 16),

          ReusableTextFieldWidget(
            controller: _descriptionController,
            label: 'Description',
            maxLines: 4,
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
