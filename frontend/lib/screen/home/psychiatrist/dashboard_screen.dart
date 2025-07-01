import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:depression_diagnosis_system/service/lib/session_service.dart';
import 'package:depression_diagnosis_system/service/lib/patient_service.dart';

import '../../../widget/widget_exporter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _sessionService = SessionService();
  final _patientService = PatientService();

  int _totalPatients = 0;
  int _totalSessions = 0;
  int _weeklySessions = 0;
  int _monthlySessions = 0;
  Map<String, int> _weeklySessionCounts = {};

  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final patients = await _patientService.getPatientsByPsychiatrist();
      final sessions = await _sessionService.getSessionsByPsychiatrist();
      _processSessionData(sessions);

      setState(() {
        _totalPatients = patients.length;
        _totalSessions = sessions.length;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _processSessionData(List<dynamic> sessions) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    final counts = {
      "Mon": 0,
      "Tue": 0,
      "Wed": 0,
      "Thu": 0,
      "Fri": 0,
      "Sat": 0,
      "Sun": 0,
    };

    int weeklyTotal = 0;
    int monthlyTotal = 0;

    for (final session in sessions) {
      final date = DateTime.parse(session['date']);
      final day = DateFormat('EEE').format(date);

      if (!counts.containsKey(day)) continue;
      if (date.isAfter(startOfWeek) || date.isAtSameMomentAs(startOfWeek)) {
        counts[day] = (counts[day] ?? 0) + 1;
        weeklyTotal++;
      }
      if (date.isAfter(startOfMonth) || date.isAtSameMomentAs(startOfMonth)) {
        monthlyTotal++;
      }
    }

    setState(() {
      _weeklySessionCounts = counts;
      _weeklySessions = weeklyTotal;
      _monthlySessions = monthlyTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_hasError) {
      return const Scaffold(
        body: Center(child: Text("Failed to load dashboard")),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildSummaryCard(
                "Total Patients",
                _totalPatients,
                Icons.person,
                Colors.deepPurple,
              ),
              _buildSummaryCard(
                "Total Sessions",
                _totalSessions,
                Icons.event,
                Colors.teal,
              ),
              _buildSummaryCard(
                "This Week",
                _weeklySessions,
                Icons.date_range,
                Colors.orange,
              ),
              _buildSummaryCard(
                "This Month",
                _monthlySessions,
                Icons.calendar_today,
                Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 89),
          const Text(
            "Weekly Session Overview",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 32),
          _buildWeeklyLineGraph(colorScheme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 600 ? 260 : double.infinity,
      child: ReusableCardWidget(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      count.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
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

  Widget _buildWeeklyLineGraph(ColorScheme colorScheme) {
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final spots = List<FlSpot>.generate(days.length, (i) {
      final value = _weeklySessionCounts[days[i]]?.toDouble() ?? 0.0;
      return FlSpot(i.toDouble(), value);
    });

    final maxY =
        (_weeklySessionCounts.values.fold<int>(0, (a, b) => a > b ? a : b) + 1)
            .toDouble();

    return SizedBox(
      height: 500,
      child: ReusableCardWidget(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: maxY,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget:
                        (value, _) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                    reservedSize: 32,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, _) {
                      if (value >= 0 && value < days.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Text(
                            days[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    reservedSize: 55,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: colorScheme.primary,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
