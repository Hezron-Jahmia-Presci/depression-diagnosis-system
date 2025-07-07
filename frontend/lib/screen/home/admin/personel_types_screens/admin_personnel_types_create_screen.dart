import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/personnel_types_service.dart';
import '../../../../widget/widget_exporter.dart';

class AdminCreatePersonnelTypesScreen extends StatefulWidget {
  const AdminCreatePersonnelTypesScreen({super.key});

  @override
  State<AdminCreatePersonnelTypesScreen> createState() =>
      _AdminCreatePersonnelTypesScreenState();
}

class _AdminCreatePersonnelTypesScreenState
    extends State<AdminCreatePersonnelTypesScreen> {
  final _formKey = GlobalKey<FormState>();
  final PersonnelTypeService _personnelTypeService = PersonnelTypeService();

  final _nameController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createPersonnelType() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final response = await _personnelTypeService.createPersonnelType({
      'name': _nameController.text.trim(),
    });

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (response != null && response['error'] == null) {
      ReusableSnackbarWidget.show(
        context,
        'Personnel type created successfully!',
      );
      _formKey.currentState!.reset();
      _nameController.clear();
    } else {
      final error = response?['error'] ?? 'Failed to create personnel type';
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
                  "Create Personnel Type",
                  style: TextStyle(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                ReusableTextFieldWidget(
                  controller: _nameController,
                  label: "Personnel Type Name",
                  autofillHints: const [],
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Personnel type name is required ⛔";
                    }
                    if (val.trim().length < 3) {
                      return "Name should be at least 3 characters";
                    }
                    return null;
                  },
                  maxLines: 1,
                ),

                const SizedBox(height: 33),

                ReusableButtonWidget(
                  isLoading: _isSubmitting,
                  onPressed: _createPersonnelType,
                  text: "Create Personnel Type",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
