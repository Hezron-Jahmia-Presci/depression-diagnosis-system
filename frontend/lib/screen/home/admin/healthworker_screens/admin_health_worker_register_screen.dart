import 'dart:io';
import 'package:depression_diagnosis_system/service/lib/department_service.dart';
import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/personnel_types_service.dart';
import 'package:depression_diagnosis_system/service/lib/health_worker_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../../../../constants/data_constants.dart';
import '../../../../widget/widget_exporter.dart';

class AdminHealthWorkerRegisterScreen extends StatefulWidget {
  const AdminHealthWorkerRegisterScreen({super.key});

  @override
  State<AdminHealthWorkerRegisterScreen> createState() =>
      _AdminHealthWorkerRegisterScreenState();
}

class _AdminHealthWorkerRegisterScreenState
    extends State<AdminHealthWorkerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final HealthWorkerService _healthWorkerService = HealthWorkerService();
  final PersonnelTypeService _personnelTypeService = PersonnelTypeService();
  final DepartmentService _departmentService = DepartmentService();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _personnelTypeController = TextEditingController();
  final _jobTitleController = TextEditingController();

  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _bioController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _educationLevelController = TextEditingController();
  final _yearsOfPracticeController = TextEditingController();

  final _passwordController = TextEditingController();

  List<Map<String, dynamic>> _personnelTypes = [];
  String? _selectedPersonnelTypeId;

  List<Map<String, dynamic>> _departments = [];
  String? _selectedDepartmentId;

  List<Map<String, dynamic>> _supervisors = [];
  String? _selectedSupervisorId;

  String? _selectedRole = 'healthworker';

  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadPersonnelTypes();
    _loadDepartments();
    _loadSupervisors();
  }

  Future<void> _loadPersonnelTypes() async {
    try {
      final types = await _personnelTypeService.getAllPersonnelTypes();
      setState(() {
        _personnelTypes = types.cast<Map<String, dynamic>>();
      });
    } catch (_) {}
  }

  Future<void> _loadDepartments() async {
    try {
      final depts = await _departmentService.getAllDepartments();
      setState(() {
        _departments = depts;
      });
    } catch (_) {}
  }

  Future<void> _loadSupervisors() async {
    try {
      final list = await _healthWorkerService.getAllHealthWorkers();
      setState(() {
        _supervisors = list;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _personnelTypeController.dispose();
    _jobTitleController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _bioController.dispose();
    _qualificationController.dispose();
    _educationLevelController.dispose();
    _yearsOfPracticeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPersonnelTypeId == null) {
      ReusableSnackbarWidget.show(context, 'Please select a personnel type');
      return;
    }

    setState(() => _isSubmitting = true);

    final response = await _healthWorkerService.createHealthWorker({
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'personnel_type_id': int.parse(_selectedPersonnelTypeId!),
      'job_title': _jobTitleController.text.trim(),
      if (_selectedImage != null)
        'image': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: 'passport.jpg',
        ),
      'address': _addressController.text.trim(),
      'contact': _contactController.text.trim(),
      'bio': _bioController.text.trim(),
      'qualification': _qualificationController.text.trim(),
      'education_level': _educationLevelController.text.trim(),
      'years_of_practice': int.parse(_yearsOfPracticeController.text),
      'department_id': int.parse(_selectedDepartmentId!),
      'supervisor_id': int.parse(_selectedSupervisorId!),
      'role': _selectedRole ?? 'healthworker',
      'password': _passwordController.text,

      // no employee_id here, backend generates it
    });

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (response != null && response['error'] == null) {
      ReusableSnackbarWidget.show(
        context,
        'Health Worker registered successfully',
      );
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
    return Padding(
      padding: EdgeInsets.all(55.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Register a Health Worker Account",
                  style: TextStyle(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                ReusableTextFieldWidget(
                  controller: _firstNameController,
                  label: 'First Name',
                  autofillHints: const [AutofillHints.givenName],
                  validator:
                      (val) =>
                          val == null || val.isEmpty
                              ? 'Enter first name'
                              : null,
                  maxLines: 1,
                ),

                const SizedBox(height: 16),
                ReusableTextFieldWidget(
                  controller: _lastNameController,
                  label: 'Last Name',
                  autofillHints: const [AutofillHints.familyName],
                  validator:
                      (val) =>
                          val == null || val.isEmpty ? 'Enter last name' : null,
                  maxLines: 1,
                ),

                const SizedBox(height: 16),
                ReusableTextFieldWidget(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter your email';
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    return emailRegex.hasMatch(val)
                        ? null
                        : 'Enter a valid email';
                  },
                  maxLines: 1,
                ),

                const SizedBox(height: 16),

                ReusableDropdownWidget(
                  selectedValue: _selectedPersonnelTypeId,
                  items: _personnelTypes,
                  onChanged:
                      (val) => setState(() => _selectedPersonnelTypeId = val),
                  label: "Select Personnel Type",
                  validator:
                      (val) =>
                          val == null ? "Personnel type is required ⛔" : null,
                  listItems: 'name',
                ),
                const SizedBox(height: 16),
                ReusableTextFieldWidget(
                  controller: _jobTitleController,
                  label: 'Job Title',
                  autofillHints: [],
                  maxLines: 1,
                ),

                const SizedBox(height: 16),
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Image.file(
                      _selectedImage!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),

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
                  controller: _addressController,
                  label: 'Address',
                  autofillHints: [],
                  maxLines: 1,
                ),

                const SizedBox(height: 16),
                ReusableTextFieldWidget(
                  controller: _contactController,
                  label: 'Contact',
                  keyboardType: TextInputType.phone,
                  autofillHints: [],
                  maxLines: 1,
                ),

                const SizedBox(height: 16),
                ReusableTextFieldWidget(
                  controller: _bioController,
                  label: 'Bio',
                  maxLines: 5,
                  autofillHints: [],
                ),

                const SizedBox(height: 16),
                ReusableTextFieldWidget(
                  controller: _qualificationController,
                  label: 'Qualification',
                  autofillHints: [],
                  maxLines: 1,
                ),

                const SizedBox(height: 16),
                ReusableTextFieldWidget(
                  controller: _educationLevelController,
                  label: 'Education Level',
                  maxLines: 1,
                  autofillHints: [],
                ),

                const SizedBox(height: 16),
                ReusableTextFieldWidget(
                  controller: _yearsOfPracticeController,
                  label: 'Years of Practice',
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return null;
                    final n = int.tryParse(val);
                    if (n == null || n < 0) return 'Enter a valid number';
                    return null;
                  },
                  autofillHints: [],
                  maxLines: 1,
                ),
                const SizedBox(height: 16),

                ReusableDropdownWidget(
                  selectedValue: _selectedDepartmentId,
                  items: _departments,
                  onChanged:
                      (val) => setState(() => _selectedDepartmentId = val),
                  label: "Select Department",
                  listItems: 'name',
                ),

                const SizedBox(height: 16),

                ReusableDropdownWidget(
                  selectedValue: _selectedSupervisorId,
                  items: _supervisors,
                  onChanged:
                      (val) => setState(() => _selectedSupervisorId = val),
                  label: "Select Supervisor",
                  listItems: 'first_name',
                  secondListItem: 'last_name',
                ),

                const SizedBox(height: 16),
                ReusableDropdownWidget(
                  selectedValue: _selectedRole,
                  items: kRoles,
                  onChanged: (val) => setState(() => _selectedRole = val),
                  label: "Select Role",
                  listItems: 'name',
                ),

                const SizedBox(height: 16),
                ReusableTextFieldWidget(
                  controller: _passwordController,
                  label: 'Set Password',
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  validator:
                      (val) =>
                          val == null || val.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  ),
                  maxLines: 1,
                ),

                const SizedBox(height: 24),
                ReusableButtonWidget(
                  text: 'Register',
                  isLoading: _isSubmitting,
                  onPressed: _register,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
