
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceCorrectionRequestScreen extends StatefulWidget {
  const AttendanceCorrectionRequestScreen({super.key});

  @override
  State<AttendanceCorrectionRequestScreen> createState() =>
      _AttendanceCorrectionRequestScreenState();
}

class _AttendanceCorrectionRequestScreenState
    extends State<AttendanceCorrectionRequestScreen> {
  static const String _requestsKey =
      'officecheck_attendance_correction_requests';

  static const String _historyKey = 'officecheck_attendance_history';

  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  DateTime _attendanceDate = DateTime.now();
  TimeOfDay _requestedTime = const TimeOfDay(hour: 9, minute: 0);
  String _reason = 'forgot';

  bool _isSaving = false;

  final Map<String, String> _reasons = const {
    'forgot': 'Forgot to check in',
    'app_issue': 'App or location issue',
    'other': 'Other reason',
  };

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  DateTime get _requestedDateTime {
    return DateTime(
      _attendanceDate.year,
      _attendanceDate.month,
      _attendanceDate.day,
      _requestedTime.hour,
      _requestedTime.minute,
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _attendanceDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'Select attendance date',
    );

    if (picked != null && mounted) {
      setState(() {
        _attendanceDate = DateUtils.dateOnly(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _requestedTime,
      helpText: 'Select first check-in time',
    );

    if (picked != null && mounted) {
      setState(() {
        _requestedTime = picked;
      });
    }
  }

  Future<String?> _getOriginalCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    final rawHistory = prefs.getString(_historyKey);

    if (rawHistory == null || rawHistory.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawHistory);

      if (decoded is! List) return null;

      for (final item in decoded) {
        if (item is! Map) continue;

        if (item['date'] != _dateKey(_attendanceDate)) {
          continue;
        }

        final sessions = item['sessions'];

        if (sessions is! List || sessions.isEmpty) {
          return null;
        }

        // The first session represents the first check-in of the day.
        final firstSession = sessions.first;

        if (firstSession is! Map) return null;

        final value = firstSession['checkInTime'];

        return value?.toString();
      }
    } catch (_) {
      // Do not prevent a correction request if history cannot be read.
    }

    return null;
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final requestedAt = _requestedDateTime;

    if (requestedAt.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Requested check-in time cannot be in the future.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      final originalCheckIn = await _getOriginalCheckIn();

      final rawRequests = prefs.getString(_requestsKey);
      final List<dynamic> requests =
      rawRequests == null || rawRequests.isEmpty
          ? []
          : jsonDecode(rawRequests) as List<dynamic>;

      final date = _dateKey(_attendanceDate);

      // Prevent multiple pending requests for the same attendance date.
      final alreadyPending = requests.any((item) {
        if (item is! Map) return false;

        return item['attendanceDate'] == date &&
            item['status'] == 'pending';
      });

      if (alreadyPending) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A correction request is already pending for this date.',
            ),
          ),
        );
        return;
      }

      final request = AttendanceCorrectionRequest(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        attendanceDate: date,
        requestedCheckInTime: requestedAt.toIso8601String(),
        originalCheckInTime: originalCheckIn,
        reason: _reason,
        note: _noteController.text.trim(),
        submittedAt: now.toIso8601String(),
        status: 'pending',
        reviewNote: null,
      );

      requests.add(request.toJson());

      await prefs.setString(
        _requestsKey,
        jsonEncode(requests),
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 42,
          ),
          title: const Text('Request saved'),
          content: const Text(
            'Your attendance correction request has been saved '
                'with Pending status.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        ),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the correction request.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText =
        '${_attendanceDate.day.toString().padLeft(2, '0')}/'
        '${_attendanceDate.month.toString().padLeft(2, '0')}/'
        '${_attendanceDate.year}';

    final timeText = _requestedTime.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Correction'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Forgot to check in? Submit your actual first '
                            'check-in time for review. Your existing attendance '
                            'record will not be changed by this request.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Correction details',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              const Text('Attendance date'),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(dateText),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Requested first check-in time'),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _selectTime,
                icon: const Icon(Icons.access_time),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(timeText),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Reason for correction'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _reason,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _reasons.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _reason = value);
                  }
                },
              ),
              const SizedBox(height: 20),

              const Text('Additional note (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                maxLength: 300,
                decoration: const InputDecoration(
                  hintText: 'Explain what happened...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.pending_outlined),
                label: const Text('Status: Pending after submission'),
              ),
              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: _isSaving ? null : _submitRequest,
                icon: _isSaving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.send_outlined),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    _isSaving ? 'Saving...' : 'Submit correction request',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceCorrectionRequest {
  const AttendanceCorrectionRequest({
    required this.id,
    required this.attendanceDate,
    required this.requestedCheckInTime,
    required this.originalCheckInTime,
    required this.reason,
    required this.note,
    required this.submittedAt,
    required this.status,
    required this.reviewNote,
  });

  final String id;
  final String attendanceDate;
  final String requestedCheckInTime;
  final String? originalCheckInTime;
  final String reason;
  final String note;
  final String submittedAt;
  final String status;
  final String? reviewNote;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attendanceDate': attendanceDate,
      'requestedCheckInTime': requestedCheckInTime,
      'originalCheckInTime': originalCheckInTime,
      'reason': reason,
      'note': note,
      'submittedAt': submittedAt,
      'status': status,
      'reviewNote': reviewNote,
    };
  }

  factory AttendanceCorrectionRequest.fromJson(
      Map<String, dynamic> json,
      ) {
    return AttendanceCorrectionRequest(
      id: json['id'] as String,
      attendanceDate: json['attendanceDate'] as String,
      requestedCheckInTime: json['requestedCheckInTime'] as String,
      originalCheckInTime: json['originalCheckInTime'] as String?,
      reason: json['reason'] as String,
      note: json['note'] as String? ?? '',
      submittedAt: json['submittedAt'] as String,
      status: json['status'] as String? ?? 'pending',
      reviewNote: json['reviewNote'] as String?,
    );
  }
}
