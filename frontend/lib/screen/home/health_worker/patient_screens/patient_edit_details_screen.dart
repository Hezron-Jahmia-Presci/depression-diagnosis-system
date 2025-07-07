import 'dart:io';
import 'package:depression_diagnosis_system/constants/data_constants.dart';
import 'package:depression_diagnosis_system/service/lib/department_service.dart';
import 'package:depression_diagnosis_system/service/lib/health_worker_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:depression_diagnosis_system/service/lib/patient_service.dart';
import 'package:intl/intl.dart';
import '../../../../../widget/widget_exporter.dart';

class EditPatientDetailsScreen extends StatefulWidget {
  final int patientId;
  final VoidCallback onBack;

  const EditPatientDetailsScreen({
    super.key,
    required this.patientId,
    required this.onBack,
  });

  @override
  State<EditPatientDetailsScreen> createState() =>
      _EditPatientDetailsScreenState();
}

class _EditPatientDetailsScreenState extends State<EditPatientDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final PatientService _patientService = PatientService();
  final HealthWorkerService _healthWorkerService = HealthWorkerService();
  final DepartmentService _departmentService = DepartmentService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nationalIDController = TextEditingController();
  final _patientCodeController = TextEditingController();
  final _previousDiagnosisController = TextEditingController();

  final _dateOfBirthController = TextEditingController();
  final _admissionDateController = TextEditingController();

  List<Map<String, dynamic>> _departments = [];
  String? _selectedDepartmentId;

  List<Map<String, dynamic>> _healthWorker = [];
  String? _selectedAdmittedById;

  String? _gender;
  String? _currentImageUrl;
  File? _newImageFile;

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadPatientDetails();
  }

  Future<void> _loadPatientDetails() async {
    try {
      final patient = await _patientService.getPatientByID(widget.patientId);
      final healthWorkers = await _healthWorkerService.getAllHealthWorkers();
      final departments = await _departmentService.getAllDepartments();

      if (patient != null && !patient.containsKey('error')) {
        _firstNameController.text = patient['first_name'] ?? '';
        _lastNameController.text = patient['last_name'] ?? '';
        _emailController.text = patient['email'] ?? '';
        _contactController.text = patient['contact'] ?? '';
        _addressController.text = patient['address'] ?? '';
        _descriptionController.text = patient['description'] ?? '';
        _nationalIDController.text = patient['national_id'] ?? '';
        _patientCodeController.text = patient['patient_code'] ?? '';
        _previousDiagnosisController.text = patient['previous_diagnosis'] ?? '';

        _gender = patient['gender'];
        _selectedDepartmentId = patient['department_id']?.toString();
        _selectedAdmittedById = patient['admitted_by_id']?.toString();

        final dob = DateTime.tryParse(patient['date_of_birth'] ?? '');
        _dateOfBirthController.text =
            dob != null
                ? DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(dob.toUtc())
                : '';
        final admissionDate = DateTime.tryParse(
          patient['admission_date'] ?? '',
        );
        _admissionDateController.text =
            admissionDate != null
                ? DateFormat(
                  "yyyy-MM-dd'T'HH:mm:ss'Z'",
                ).format(admissionDate.toUtc())
                : '';

        _currentImageUrl = patient['image_url'];

        setState(() {
          _departments = departments;
          _healthWorker = healthWorkers;
          _isLoading = false;
        });
      } else {
        _setError();
      }
    } catch (_) {
      _setError();
    }
  }

  void _setError() {
    setState(() {
      _isLoading = false;
      _hasError = true;
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newImageFile = File(picked.path);
      });
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'contact': _contactController.text.trim(),
      'address': _addressController.text.trim(),
      'description': _descriptionController.text.trim(),
      'gender': _gender,
      'date_of_birth': _dateOfBirthController.text.trim(),
      'national_id': _nationalIDController.text.trim(),
      'admission_date': _admissionDateController.text.trim(),
      'department_id': int.tryParse(_selectedDepartmentId ?? ''),
      'admitted_by_id': int.tryParse(_selectedAdmittedById ?? ''),
    };

    final response = await _patientService.updatePatient(
      widget.patientId,
      data,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (response != null && response['error'] == null) {
      ReusableSnackbarWidget.show(context, 'Patient updated successfully');
      widget.onBack();
    } else {
      ReusableSnackbarWidget.show(
        context,
        response?['error'] ?? 'Update failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_hasError) return const Center(child: Text('Failed to load patient'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: widget.onBack,
            ),
            const Text(
              'Edit Patient',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundImage:
                  _newImageFile != null
                      ? FileImage(_newImageFile!)
                      : (_currentImageUrl != null &&
                          _currentImageUrl!.isNotEmpty)
                      ? NetworkImage(_currentImageUrl!)
                      : null,
              child:
                  (_newImageFile == null &&
                          (_currentImageUrl == null ||
                              _currentImageUrl!.isEmpty))
                      ? Icon(Icons.person_outline_rounded, size: 60)
                      : null,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            children: [
              ReusableTextFieldWidget(
                label: 'First Name',
                controller: _firstNameController,
                validator: _required,
                autofillHints: const [],
              ),
              const SizedBox(height: 16),

              ReusableTextFieldWidget(
                label: 'Last Name',
                controller: _lastNameController,
                validator: _required,
                autofillHints: const [],
              ),
              const SizedBox(height: 16),

              ReusableTextFieldWidget(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [],
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),

              ReusableTextFieldWidget(
                label: 'Contact',
                controller: _contactController,
                autofillHints: const [],
              ),
              const SizedBox(height: 16),

              ReusableTextFieldWidget(
                label: 'Address',
                controller: _addressController,
                autofillHints: const [],
              ),
              const SizedBox(height: 16),

              ReusableDropdownWidget(
                selectedValue: _gender,
                label: 'Gender',
                items: genderItems,
                onChanged: (val) => setState(() => _gender = val),
                listItems: 'name',
                validator: (val) => val == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ReusableDateTimePickerField(
                controller: _dateOfBirthController,
                label: 'Date of Birth',
              ),

              const SizedBox(height: 16),

              ReusableTextFieldWidget(
                label: 'National ID',
                controller: _nationalIDController,
                autofillHints: [],
              ),
              const SizedBox(height: 16),

              ReusableDateTimePickerField(
                controller: _admissionDateController,
                label: 'Select Date and Time',
              ),

              const SizedBox(height: 16),

              ReusableDropdownWidget(
                selectedValue: _selectedDepartmentId,
                items: _departments,
                onChanged: (val) => setState(() => _selectedDepartmentId = val),
                label: "Department",
                listItems: 'name',
                validator: (val) => val == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              ReusableDropdownWidget(
                selectedValue: _selectedAdmittedById,
                items: _healthWorker,
                onChanged: (val) => setState(() => _selectedAdmittedById = val),
                label: "Admitted By",
                listItems: 'first_name',
                validator: (val) => val == null ? 'Required' : null,
              ),

              const SizedBox(height: 16),

              ReusableTextFieldWidget(
                label: 'Previous Diagnosis',
                controller: _previousDiagnosisController,
                autofillHints: const [],
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 32),
              ReusableButtonWidget(
                text: 'Save Changes',
                isLoading: _isSubmitting,
                onPressed: _submitUpdate,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  String? _required(String? val) =>
      val == null || val.isEmpty ? 'Required' : null;
  String? _validateEmail(String? val) =>
      val == null || !val.contains('@') ? 'Enter a valid email' : null;
}
