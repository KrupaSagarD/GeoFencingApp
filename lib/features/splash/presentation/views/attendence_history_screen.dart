
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  static const String _historyKey = 'officecheck_attendance_history';

  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.get(_historyKey);

      final records = <Map<String, dynamic>>[];

      void addRecord(dynamic item) {
        try {
          dynamic decoded = item;

          if (decoded is String) {
            decoded = jsonDecode(decoded);
          }

          if (decoded is Map) {
            final record = Map<String, dynamic>.from(decoded);
            final sessions = record['sessions'];

            if (sessions is List && sessions.isNotEmpty) {
              records.add(record);
            }
          }
        } catch (e) {
          debugPrint('Skipping invalid attendance record: $e');
        }
      }

      if (savedData is String) {
        // Supports one JSON string containing a list or a single record.
        final decoded = jsonDecode(savedData);

        if (decoded is List) {
          for (final item in decoded) {
            addRecord(item);
          }
        } else {
          addRecord(decoded);
        }
      } else if (savedData is List<String>) {
        // Supports a StringList containing individual JSON records.
        for (final item in savedData) {
          addRecord(item);
        }
      } else if (savedData != null) {
        debugPrint(
          'Unexpected attendance history type: ${savedData.runtimeType}',
        );
      }

      records.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['date']?.toString() ?? '') ??
                DateTime(1970);
        final dateB =
            DateTime.tryParse(b['date']?.toString() ?? '') ??
                DateTime(1970);

        return dateB.compareTo(dateA);
      });

      if (!mounted) return;

      setState(() {
        _records = records;
        _isLoading = false;
      });

      debugPrint('Attendance history records loaded: ${records.length}');
    } catch (e, stackTrace) {
      debugPrint('Failed to load attendance history: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _records = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load attendance history. Check debug logs.'),
        ),
      );
    }
  }

  DateTime? _parseTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString())?.toLocal();
  }

  String _formatTime(dynamic value) {
    final time = _parseTime(value);
    if (time == null) return '--:--';

    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _formatDate(String? value) {
    final date = DateTime.tryParse(value ?? '');
    if (date == null) return value ?? 'Unknown date';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Duration _calculateTotal(List sessions) {
    var total = Duration.zero;
    final now = DateTime.now();

    for (final item in sessions) {
      if (item is! Map) continue;

      final checkIn = _parseTime(item['checkInTime']);
      final checkOut = _parseTime(item['checkOutTime']);

      if (checkIn == null) continue;

      final end = checkOut ?? now;
      if (end.isAfter(checkIn)) {
        total += end.difference(checkIn);
      }
    }

    return total;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '${hours}h ${minutes}m';
  }

  void _showSessions(Map<String, dynamic> record) {
    final sessions = record['sessions'] as List? ?? [];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(record['date']?.toString()),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...List.generate(sessions.length, (index) {
                  final session = sessions[index] as Map;
                  final checkOut = session['checkOutTime'];

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        'Check in: ${_formatTime(session['checkInTime'])}',
                      ),
                      subtitle: Text(
                        checkOut == null
                            ? 'Check out: Not recorded'
                            : 'Check out: ${_formatTime(checkOut)}',
                      ),
                      trailing: const Icon(Icons.access_time),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Text(
                  'Total worked: ${_formatDuration(_calculateTotal(sessions))}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        actions: [
          IconButton(
            onPressed: _loadHistory,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_note_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No attendance history yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your completed and ongoing attendance sessions '
                    'will appear here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _records.length,
          itemBuilder: (context, index) {
            final record = _records[index];
            final sessions = record['sessions'] as List? ?? [];
            final total = _calculateTotal(sessions);

            final firstSession =
            sessions.first as Map;
            final lastSession =
            sessions.last as Map;

            final hasOpenSession =
                lastSession['checkOutTime'] == null;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _showSessions(record),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _formatDate(
                                record['date']?.toString(),
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium,
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _timeInfo(
                              'First check-in',
                              _formatTime(
                                firstSession['checkInTime'],
                              ),
                              Icons.login,
                            ),
                          ),
                          Expanded(
                            child: _timeInfo(
                              'Last check-out',
                              hasOpenSession
                                  ? 'In progress'
                                  : _formatTime(
                                lastSession['checkOutTime'],
                              ),
                              Icons.logout,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 19,
                          ),
                          const SizedBox(width: 8),
                          const Text('Total worked'),
                          const Spacer(),
                          Text(
                            _formatDuration(total),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (sessions.length > 1) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${sessions.length} attendance sessions',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _timeInfo(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}
