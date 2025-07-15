import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:depression_diagnosis_system/service/lib/session_service.dart';
import 'package:depression_diagnosis_system/service/lib/patient_service.dart';

import '../../../widget/widget_exporter.dart';

class HealthWorkerDashboardScreen extends StatefulWidget {
  const HealthWorkerDashboardScreen({super.key});

  @override
  State<HealthWorkerDashboardScreen> createState() =>
      _HealthWorkerDashboardScreenState();
}

class _HealthWorkerDashboardScreenState
    extends State<HealthWorkerDashboardScreen> {
  final _sessionService = SessionService();
  final _patientService = PatientService();

  int _totalPatients = 0;
  int _totalSessions = 0;
  int _weeklySessions = 0;
  int _monthlySessions = 0;

  Map<String, int> _weeklySessionCounts = {};

  bool _isLoading = true;
  bool _hasError = false;

  final List<String> _orderedDays = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final patients = await _patientService.getPatientsByHealthWorker();
      final sessions = await _sessionService.getSessionsByHealthWorker();
      _processSessionData(sessions);

      setState(() {
        _totalPatients = patients.length;
        _totalSessions = sessions.length;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Dashboard load error: $e");
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

    final counts = {for (var d in _orderedDays) d: 0};

    int weeklyTotal = 0;
    int monthlyTotal = 0;

    for (final session in sessions) {
      final dateStr = session['date'];
      if (dateStr == null) continue;

      try {
        final date = DateTime.parse(dateStr);
        final day = DateFormat('EEE').format(date); // e.g., Mon, Tue

        if (counts.containsKey(day)) {
          if (!date.isBefore(startOfWeek)) {
            counts[day] = counts[day]! + 1;
            weeklyTotal++;
          }
        }

        if (!date.isBefore(startOfMonth)) {
          monthlyTotal++;
        }
      } catch (e) {
        debugPrint('Invalid session date: $dateStr');
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

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      children: [
        Wrap(
          spacing: 24,
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
        const SizedBox(height: 64),
        const Text(
          "Weekly Session Overview",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(height: 32),

        _buildWeeklyLineGraph(colorScheme),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 600 ? 280 : double.infinity,
      child: ReusableCardWidget(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                      '$count',
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
    final spots = List<FlSpot>.generate(_orderedDays.length, (i) {
      final value = _weeklySessionCounts[_orderedDays[i]]?.toDouble() ?? 0.0;
      return FlSpot(i.toDouble(), value);
    });

    final maxY =
        (_weeklySessionCounts.values.fold(
                  0,
                  (prev, curr) => curr > prev ? curr : prev,
                ) +
                1)
            .toDouble();

    return SizedBox(
      height: 480,
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
                      if (value >= 0 && value < _orderedDays.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Text(
                            _orderedDays[value.toInt()],
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
                    color: colorScheme.primary.withValues(alpha: 0.2),
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
