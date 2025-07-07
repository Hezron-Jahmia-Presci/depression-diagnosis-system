import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/department_service.dart';
import 'package:depression_diagnosis_system/widget/widget_exporter.dart';

class AdminCreateDepartmentScreen extends StatefulWidget {
  const AdminCreateDepartmentScreen({super.key});

  @override
  State<AdminCreateDepartmentScreen> createState() =>
      _AdminCreateDepartmentScreenState();
}

class _AdminCreateDepartmentScreenState
    extends State<AdminCreateDepartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final DepartmentService _departmentService = DepartmentService();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createDepartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final response = await _departmentService.createDepartment({
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
    });

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (response != null && response['error'] == null) {
      ReusableSnackbarWidget.show(context, 'Department created successfully ✅');
      _nameController.clear();
      _descriptionController.clear();
    } else {
      final error = response?['error'] ?? 'Department creation failed';
      ReusableSnackbarWidget.show(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(55.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Create New Department",
                  style: TextStyle(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                ReusableTextFieldWidget(
                  controller: _nameController,
                  label: 'Department Name',
                  validator:
                      (val) =>
                          val == null || val.isEmpty
                              ? 'Enter department name'
                              : null,
                  maxLines: 1,
                  autofillHints: [],
                ),

                const SizedBox(height: 16),

                ReusableTextFieldWidget(
                  controller: _descriptionController,
                  label: 'Description',
                  maxLines: 5,
                  autofillHints: [],
                ),

                const SizedBox(height: 24),

                ReusableButtonWidget(
                  text: 'Create Department',
                  isLoading: _isSubmitting,
                  onPressed: _createDepartment,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
