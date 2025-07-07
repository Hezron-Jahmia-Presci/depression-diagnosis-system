import 'package:depression_diagnosis_system/constants/data_constants.dart';
import 'package:depression_diagnosis_system/service/lib/department_service.dart';
import 'package:depression_diagnosis_system/service/lib/personnel_types_service.dart';
import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/health_worker_service.dart';
import '../../../../widget/widget_exporter.dart';

class EditHealthWorkerDetailsScreen extends StatefulWidget {
  final int healthWorkerID;
  final VoidCallback onBack;

  const EditHealthWorkerDetailsScreen({
    super.key,
    required this.healthWorkerID,
    required this.onBack,
  });

  @override
  State<EditHealthWorkerDetailsScreen> createState() =>
      _EditHealthWorkerDetailsScreenState();
}

class _EditHealthWorkerDetailsScreenState
    extends State<EditHealthWorkerDetailsScreen> {
  final HealthWorkerService _healthWorkerService = HealthWorkerService();
  final PersonnelTypeService _personnelTypeService = PersonnelTypeService();
  final DepartmentService _departmentService = DepartmentService();
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _addressController = TextEditingController();
  final _educationLevelController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _bioController = TextEditingController();
  final _yearsOfPracticeController = TextEditingController();

  List<Map<String, dynamic>> _personnelTypes = [];
  String? _selectedPersonnelTypeId;

  List<Map<String, dynamic>> _departments = [];
  String? _selectedDepartmentId;

  List<Map<String, dynamic>> _supervisors = [];
  String? _selectedSupervisorId;

  String? _selectedRole;

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final details = await _healthWorkerService.getHealthWorkerById();
      final personnelTypes = await _personnelTypeService.getAllPersonnelTypes();
      final departments = await _departmentService.getAllDepartments();
      final supervisors = await _healthWorkerService.getAllHealthWorkers();

      if (details != null && !details.containsKey('error')) {
        _firstNameController.text = details['first_name'] ?? '';
        _lastNameController.text = details['last_name'] ?? '';
        _emailController.text = details['email'] ?? '';
        _contactController.text = details['contact'] ?? '';
        _jobTitleController.text = details['job_title'] ?? '';
        _addressController.text = details['address'] ?? '';
        _educationLevelController.text = details['education_level'] ?? '';
        _qualificationController.text = details['qualification'] ?? '';
        _bioController.text = details['bio'] ?? '';
        _yearsOfPracticeController.text =
            details['years_of_practice']?.toString() ?? '';
        _selectedPersonnelTypeId = details['personnel_type_id']?.toString();
        _selectedDepartmentId = details['department_id']?.toString();
        _selectedSupervisorId = details['supervisor_id']?.toString();
        _selectedRole = details['role'];

        setState(() {
          _personnelTypes = personnelTypes;
          _departments = departments;
          _supervisors = supervisors;
        });
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

    final data = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'contact': _contactController.text.trim(),
      'job_title': _jobTitleController.text.trim(),
      'address': _addressController.text.trim(),
      'education_level': _educationLevelController.text.trim(),
      'qualification': _qualificationController.text.trim(),
      'bio': _bioController.text.trim(),
      'years_of_practice': int.tryParse(_yearsOfPracticeController.text) ?? 0,
      'personnel_type_id': int.tryParse(_selectedPersonnelTypeId ?? ''),
      'department_id': int.tryParse(_selectedDepartmentId ?? ''),
      'supervisor_id': int.tryParse(_selectedSupervisorId ?? ''),
      'role': _selectedRole,
    };

    final result = await _healthWorkerService.updateHealthWorker(
      widget.healthWorkerID,
      data,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result != null && result['error'] == null) {
      ReusableSnackbarWidget.show(context, 'Details updated successfully!');
    } else {
      ReusableSnackbarWidget.show(
        context,
        result?['error'] ?? 'Failed to update details',
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _jobTitleController.dispose();
    _addressController.dispose();
    _educationLevelController.dispose();
    _qualificationController.dispose();
    _bioController.dispose();
    _yearsOfPracticeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_hasError) return const Center(child: Text('Failed to load details.'));

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
                'Edit Profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),

          ReusableTextFieldWidget(
            controller: _firstNameController,
            label: 'First Name',
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            autofillHints: const [AutofillHints.givenName],
          ),
          const SizedBox(height: 16),

          ReusableTextFieldWidget(
            controller: _lastNameController,
            label: 'Last Name',
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            autofillHints: const [AutofillHints.familyName],
          ),
          const SizedBox(height: 16),

          ReusableTextFieldWidget(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator:
                (val) =>
                    val == null || !val.contains('@') ? 'Invalid email' : null,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 16),

          ReusableDropdownWidget(
            selectedValue: _selectedPersonnelTypeId,
            items: _personnelTypes,
            onChanged: (val) => setState(() => _selectedPersonnelTypeId = val),
            label: "Personnel Type",
            listItems: 'name',
            validator: (val) => val == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          ReusableTextFieldWidget(
            controller: _jobTitleController,
            label: 'Job Title',
            autofillHints: [],
          ),
          const SizedBox(height: 16),

          ReusableTextFieldWidget(
            controller: _addressController,
            label: 'Address',
            autofillHints: [],
          ),
          const SizedBox(height: 16),

          ReusableTextFieldWidget(
            controller: _contactController,
            label: 'Contact',
            keyboardType: TextInputType.phone,
            autofillHints: [],
          ),
          const SizedBox(height: 16),

          ReusableTextFieldWidget(
            controller: _bioController,
            label: 'Bio',
            maxLines: 4,
            autofillHints: [],
          ),
          const SizedBox(height: 16),

          ReusableTextFieldWidget(
            controller: _qualificationController,
            label: 'Qualification',
            autofillHints: [],
          ),
          const SizedBox(height: 16),

          ReusableTextFieldWidget(
            controller: _educationLevelController,
            label: 'Education Level',
            autofillHints: [],
          ),
          const SizedBox(height: 16),

          ReusableTextFieldWidget(
            controller: _yearsOfPracticeController,
            label: 'Years of Practice',
            keyboardType: TextInputType.number,
            validator: (val) {
              if (val != null && val.isNotEmpty) {
                final n = int.tryParse(val);
                if (n == null || n < 0) return 'Invalid number';
              }
              return null;
            },
            autofillHints: [],
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
            selectedValue: _selectedSupervisorId,
            items: _supervisors,
            onChanged: (val) => setState(() => _selectedSupervisorId = val),
            label: "Supervisor",
            listItems: 'first_name',
          ),
          const SizedBox(height: 16),

          ReusableDropdownWidget(
            selectedValue: _selectedRole,
            items: kRoles,
            onChanged: (val) => setState(() => _selectedRole = val),
            label: "Role",
            listItems: 'name',
            validator: (val) => val == null ? 'Required' : null,
          ),

          const SizedBox(height: 28),
          ReusableButtonWidget(
            text: 'Save Changes',
            isLoading: _isSubmitting,
            onPressed: _submitUpdate,
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
