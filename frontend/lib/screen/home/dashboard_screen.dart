import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/widget/reusable_card_widget.dart';
import 'package:intl/intl.dart';
import '../../service/session_service.dart' show SessionService;
import '../../service/patient_service.dart' show PatientService;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SessionService _sessionService = SessionService();
  final PatientService _patientService = PatientService();

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
      _processSessionData(sessions!);

      setState(() {
        _totalPatients = patients?.length ?? 0;
        _totalSessions = sessions.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _processSessionData(List<dynamic> sessions) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime startOfMonth = DateTime(now.year, now.month, 1);

    Map<String, int> weeklyCounts = {
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

    for (var session in sessions) {
      DateTime sessionDate = DateTime.parse(session['date']);
      String dayOfWeek = DateFormat('EEE').format(sessionDate);

      if (sessionDate.isAfter(startOfWeek) ||
          sessionDate.isAtSameMomentAs(startOfWeek)) {
        weeklyCounts[dayOfWeek] = (weeklyCounts[dayOfWeek] ?? 0) + 1;
        weeklyTotal++;
      }

      if (sessionDate.isAfter(startOfMonth) ||
          sessionDate.isAtSameMomentAs(startOfMonth)) {
        monthlyTotal++;
      }
    }

    setState(() {
      _weeklySessionCounts = weeklyCounts;
      _weeklySessions = weeklyTotal;
      _monthlySessions = monthlyTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'DASHBOARD',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasError
              ? const Center(child: Text('No summaries to show'))
              : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 21,
                  vertical: 13,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            "Total Patients",
                            _totalPatients,
                            Icons.person,
                            colorScheme,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildSummaryCard(
                            "Total Sessions",
                            _totalSessions,
                            Icons.event,
                            colorScheme,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            "This Week",
                            _weeklySessions,
                            Icons.date_range,
                            colorScheme,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: _buildSummaryCard(
                            "This Month",
                            _monthlySessions,
                            Icons.calendar_today,
                            colorScheme,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        "WEEKLY SESSON SUMMARY GRAPH",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(),
                    _buildWeeklyLineGraph(colorScheme),
                  ],
                ),
              ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    int count,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return ReusableCardWidget(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 40, color: colorScheme.primary),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyLineGraph(ColorScheme colorScheme) {
    List<FlSpot> spots = [];
    List<String> daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    for (int i = 0; i < daysOfWeek.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), _weeklySessionCounts[daysOfWeek[i]]!.toDouble()),
      );
    }

    return SizedBox(
      height: MediaQuery.sizeOf(context).height / 2.5,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: daysOfWeek.length - 1,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: colorScheme.primary,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: colorScheme.secondary.withAlpha(70),
                  ),
                  dotData: FlDotData(show: true),
                ),
              ],
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value >= 0 && value < daysOfWeek.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Text(
                            daysOfWeek[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    reservedSize: 55,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 0,
                    color: Colors.transparent,
                    strokeWidth: 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
