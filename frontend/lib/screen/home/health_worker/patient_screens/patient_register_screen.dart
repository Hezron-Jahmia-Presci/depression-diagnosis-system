import 'dart:io';
import 'package:depression_diagnosis_system/constants/data_constants.dart';
import 'package:depression_diagnosis_system/service/lib/department_service.dart';
import 'package:depression_diagnosis_system/service/lib/health_worker_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:depression_diagnosis_system/service/lib/patient_service.dart';
import '../../../../widget/widget_exporter.dart';

class RegisterPatientScreen extends StatefulWidget {
  const RegisterPatientScreen({super.key});

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final PatientService _patientService = PatientService();
  final DepartmentService _departmentService = DepartmentService();
  final HealthWorkerService _healthWorkerService = HealthWorkerService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _previousDiagnosisController = TextEditingController();

  final _dateOfBirthController = TextEditingController();
  final _dateOfAdmissionController = TextEditingController();

  List<Map<String, String>> _medicationHistories = [];

  final _medPrescriptionController = TextEditingController();
  final _medHealthCenterController = TextEditingController();
  final _medExternalDoctorNameController = TextEditingController();
  final _medExternalDoctorContactController = TextEditingController();
  String? _selectedPrescribingDoctorId;

  List<Map<String, dynamic>> _departments = [];
  String? _selectedDepartmentId;

  List<Map<String, dynamic>> _healthWorkers = [];
  String? _selectedAdmittedById;

  String? _selectedGender;
  File? _selectedImage;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final departments = await _departmentService.getAllDepartments();
    final healthWorkers = await _healthWorkerService.getAllHealthWorkers();

    setState(() {
      _departments = departments;
      _healthWorkers = healthWorkers;
    });
  }

  Future<void> _registerPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final response = await _patientService.registerPatient({
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'contact': _contactController.text.trim(),
      'gender': _selectedGender,
      'date_of_birth': _dateOfBirthController.text.trim(),
      'national_id': _nationalIdController.text.trim(),
      'description': _descriptionController.text.trim(),
      'admission_date': _dateOfAdmissionController.text.trim(),
      'previous_diagnosis': _previousDiagnosisController.text.trim(),

      'department_id': int.tryParse(_selectedDepartmentId ?? ''),
      'admitted_by_id': int.tryParse(_selectedAdmittedById ?? ''),
      if (_selectedImage != null)
        'image': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: 'passport.jpg',
        ),

      'medication_histories':
          _medicationHistories
              .where((mh) => mh['prescription']!.isNotEmpty)
              .map(
                (mh) => {
                  'prescription': mh['prescription'],
                  'health_center': mh['health_center'],
                  'external_doctor_name': mh['external_doctor_name'],
                  'external_doctor_contact': mh['external_doctor_contact'],
                  if (mh['prescribing_doctor_id'] != null &&
                      mh['prescribing_doctor_id']!.isNotEmpty)
                    'prescribing_doctor_id': int.tryParse(
                      mh['prescribing_doctor_id']!,
                    ),
                },
              )
              .toList(),
    });

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (response != null && response['error'] == null) {
      ReusableSnackbarWidget.show(context, 'Patient registered successfully!');
      Navigator.pop(context, true);
    } else {
      final error = response?['error'] ?? 'Registration failed';
      ReusableSnackbarWidget.show(context, error);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(55),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Register Patient",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload),
                  label: const Text("Upload Photo"),
                ),
                ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Take Photo"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ReusableTextFieldWidget(
              controller: _firstNameController,
              label: "First Name",
              autofillHints: const [AutofillHints.givenName],
            ),
            const SizedBox(height: 16),
            ReusableTextFieldWidget(
              controller: _lastNameController,
              label: "Last Name",
              autofillHints: const [AutofillHints.familyName],
            ),
            const SizedBox(height: 16),
            ReusableTextFieldWidget(
              controller: _emailController,
              label: "Email",
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 16),
            ReusableTextFieldWidget(
              controller: _addressController,
              label: "Address",
              autofillHints: const [AutofillHints.fullStreetAddress],
            ),
            const SizedBox(height: 16),
            ReusableTextFieldWidget(
              controller: _contactController,
              label: "Contact",
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
            ),
            const SizedBox(height: 16),

            ReusableDropdownWidget(
              selectedValue: _selectedGender,
              items: genderItems,
              onChanged: (val) => setState(() => _selectedGender = val),
              label: 'Gender',
              listItems: 'name',
            ),
            const SizedBox(height: 16),

            ReusableDateTimePickerField(
              controller: _dateOfBirthController,
              label: 'Date of Birth',
            ),
            const SizedBox(height: 16),
            ReusableTextFieldWidget(
              controller: _nationalIdController,
              label: "National ID",
              autofillHints: const [AutofillHints.name],
            ),
            const SizedBox(height: 16),
            ReusableTextFieldWidget(
              controller: _descriptionController,
              label: "Arrival Description",
              maxLines: 3,
              autofillHints: const [AutofillHints.name],
            ),
            const SizedBox(height: 16),

            ReusableDateTimePickerField(
              controller: _dateOfAdmissionController,
              label: 'Admission Date',
            ),
            const SizedBox(height: 16),

            ReusableDropdownWidget(
              selectedValue: _selectedDepartmentId,
              items: _departments,
              onChanged: (val) => setState(() => _selectedDepartmentId = val),
              label: "Department",
              listItems: 'name',
            ),
            const SizedBox(height: 16),

            ReusableDropdownWidget(
              selectedValue: _selectedAdmittedById,
              items: _healthWorkers,
              onChanged: (val) => setState(() => _selectedAdmittedById = val),
              label: "Admitted By",
              listItems: 'first_name',
              secondListItem: 'last_name',
            ),
            const SizedBox(height: 16),

            ReusableTextFieldWidget(
              controller: _previousDiagnosisController,
              label: "Previous Diagnosis",
              maxLines: 3,
              autofillHints: const [AutofillHints.name],
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 32),
            Text(
              "Add Medication History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            ReusableTextFieldWidget(
              controller: _medPrescriptionController,
              label: "Prescription",
              autofillHints: [],
            ),
            const SizedBox(height: 12),

            ReusableTextFieldWidget(
              controller: _medHealthCenterController,
              label: "Health Center",
              autofillHints: [],
            ),
            const SizedBox(height: 12),

            ReusableDropdownWidget(
              selectedValue: _selectedPrescribingDoctorId,
              items: _healthWorkers,
              onChanged:
                  (val) => setState(() => _selectedPrescribingDoctorId = val),
              label: "Prescribing Doctor (optional)",
              listItems: 'first_name',
              secondListItem: 'last_name',
            ),
            const SizedBox(height: 12),

            ReusableTextFieldWidget(
              controller: _medExternalDoctorNameController,
              label: "External Doctor Name",
              autofillHints: [],
            ),
            const SizedBox(height: 12),

            ReusableTextFieldWidget(
              controller: _medExternalDoctorContactController,
              label: "External Doctor Contact",
              autofillHints: [],
            ),
            const SizedBox(height: 8),

            ReusableButtonWidget(
              isLoading: _isSubmitting,
              onPressed: () {
                setState(() {
                  _medicationHistories.add({
                    'prescription': _medPrescriptionController.text,
                    'health_center': _medHealthCenterController.text,
                    'prescribing_doctor_id': _selectedPrescribingDoctorId ?? '',
                    'external_doctor_name':
                        _medExternalDoctorNameController.text,
                    'external_doctor_contact':
                        _medExternalDoctorContactController.text,
                  });

                  // Clear the fields
                  _medPrescriptionController.clear();
                  _medHealthCenterController.clear();
                  _selectedPrescribingDoctorId = null;
                  _medExternalDoctorNameController.clear();
                  _medExternalDoctorContactController.clear();
                });
              },
              text: 'Add Medication History',
            ),

            const SizedBox(height: 16),

            Text("Medication History List:"),
            ..._medicationHistories.map(
              (history) => ListTile(
                title: Text(history['prescription'] ?? ''),
                subtitle: Text("From ${history['health_center'] ?? ''}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _medicationHistories.remove(history);
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),
            ReusableButtonWidget(
              text: "Register",
              isLoading: _isSubmitting,
              onPressed: _registerPatient,
            ),
          ],
        ),
      ),
    );
  }
}
