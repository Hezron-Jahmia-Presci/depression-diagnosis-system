import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:depression_diagnosis_system/service/lib/patient_service.dart';
import 'package:depression_diagnosis_system/service/lib/session_service.dart';
import 'package:depression_diagnosis_system/service/lib/health_worker_service.dart';
import 'package:depression_diagnosis_system/service/lib/department_service.dart';
import 'package:depression_diagnosis_system/service/lib/medication_history_service.dart';

import '../../../widget/widget_exporter.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _patientService = PatientService();
  final _sessionService = SessionService();
  final _healthWorkerService = HealthWorkerService();
  final _departmentService = DepartmentService();
  final _medicationService = MedicationHistoryService();

  int _totalPatients = 0;
  int _totalSessions = 0;
  int _weeklySessions = 0;
  int _monthlySessions = 0;
  int _totalHealthWorkers = 0;
  int _totalDepartments = 0;
  int _totalMedications = 0;

  List<Map<String, dynamic>> _recentPatients = [];
  List<Map<String, dynamic>> _recentMedications = [];

  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final patients = await _patientService.getAllPatients();
      final sessions = await _sessionService.getAllSessions();
      final workers = await _healthWorkerService.getAllHealthWorkers();
      final departments = await _departmentService.getAllDepartments();
      final medications = await _medicationService.getAllMedicationHistories();

      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);

      int weekly = 0, monthly = 0;
      for (final s in sessions) {
        final dateStr = s['date'];
        if (dateStr == null) continue;

        final parsedDate = DateTime.tryParse(dateStr);
        if (parsedDate == null) continue;

        if (parsedDate.isAfter(weekStart)) weekly++;
        if (parsedDate.isAfter(monthStart)) monthly++;
      }

      patients.sort((a, b) {
        final bDate =
            DateTime.tryParse(b['admissionDate'] ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final aDate =
            DateTime.tryParse(a['admissionDate'] ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      medications.sort((a, b) {
        final bDate =
            DateTime.tryParse(b['createdAt'] ?? b['date'] ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final aDate =
            DateTime.tryParse(a['createdAt'] ?? a['date'] ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      setState(() {
        _totalPatients = patients.length;
        _totalSessions = sessions.length;
        _totalHealthWorkers = workers.length;
        _totalDepartments = departments.length;
        _totalMedications = medications.length;
        _weeklySessions = weekly;
        _monthlySessions = monthly;
        _recentPatients = patients.take(5).toList();
        _recentMedications = medications.take(5).toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_hasError) {
      return const Scaffold(body: Center(child: Text('Failed to load data')));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildCard(
                "Patients",
                _totalPatients,
                Icons.person,
                Colors.deepPurple,
              ),
              _buildCard("Sessions", _totalSessions, Icons.event, Colors.teal),
              _buildCard(
                "Health Workers",
                _totalHealthWorkers,
                Icons.group,
                Colors.indigo,
              ),
              _buildCard(
                "Departments",
                _totalDepartments,
                Icons.apartment,
                Colors.brown,
              ),
              _buildCard(
                "Medications",
                _totalMedications,
                Icons.medication,
                Colors.green,
              ),

              _buildCard(
                "Sessions This Week",
                _weeklySessions,
                Icons.calendar_view_week,
                Colors.orange,
              ),
              _buildCard(
                "Sessions This Month",
                _monthlySessions,
                Icons.calendar_month,
                Colors.blue,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionTitle("Recent Admissions"),
        ..._recentPatients.map(
          (p) => ListTile(
            leading: Icon(Icons.person_outline, color: colorScheme.primary),
            title: Text("${p['first_name']} ${p['last_name']}"),
            subtitle: Text("Admitted: ${_formatDate(p['admission_date'])}"),
            trailing: Text(
              p['patient_code'] ?? "—",
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle("Recent Medication Histories"),
        ..._recentMedications.map(
          (m) => ListTile(
            leading: Icon(Icons.medical_services, color: colorScheme.primary),
            title: Text(m['prescription'] ?? "Medication"),
            subtitle: Text(
              "Patient : ${m['Patient']['first_name'] ?? 'N/A'}  ${m['Patient']['last_name'] ?? 'N/A'}",
            ),
            trailing: Text(
              m['health_center'] ?? "—",
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    final date = DateTime.tryParse(dateString ?? '');
    return date != null ? DateFormat.yMMMd().format(date) : "—";
  }

  Widget _buildCard(String title, int count, IconData icon, Color color) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 600 ? 260 : double.infinity,
      child: ReusableCardWidget(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 24),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Expanded(child: Divider(thickness: 1, indent: 12)),
        ],
      ),
    );
  }
}
