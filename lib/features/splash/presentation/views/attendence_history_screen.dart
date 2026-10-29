import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/contants/colors.dart';
import '../../../../core/contants/sizes.dart';
import '../../../../l10n/generated/app_localizations.dart';

enum HistoryPeriod { daily, weekly, monthly }

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends State<AttendanceHistoryScreen> {
  static const String _historyKey = 'officecheck_attendance_history';

  HistoryPeriod _selectedPeriod = HistoryPeriod.daily;
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());

  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawHistory = prefs.getString(_historyKey);
      final records = <Map<String, dynamic>>[];

      if (rawHistory != null) {
        final decoded = jsonDecode(rawHistory);

        if (decoded is List) {
          for (final item in decoded) {
            if (item is! Map) continue;

            final record = Map<String, dynamic>.from(item);
            final sessions = record['sessions'];

            if (sessions is List && sessions.isNotEmpty) {
              records.add(record);
            }
          }
        }
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
    } catch (error, stackTrace) {
      debugPrint('Failed to load attendance history: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _records = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.attendanceHistoryLoadError)),
      );
    }
  }

  DateTime? _parseTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return null;

    return DateUtils.dateOnly(parsed);
  }

  DateTime get _periodStart {
    switch (_selectedPeriod) {
      case HistoryPeriod.daily:
        return _selectedDate;
      case HistoryPeriod.weekly:
        return _selectedDate.subtract(
          Duration(days: _selectedDate.weekday - 1),
        );
      case HistoryPeriod.monthly:
        return DateTime(_selectedDate.year, _selectedDate.month);
    }
  }

  DateTime get _periodEnd {
    switch (_selectedPeriod) {
      case HistoryPeriod.daily:
        return _selectedDate;
      case HistoryPeriod.weekly:
        return _periodStart.add(const Duration(days: 6));
      case HistoryPeriod.monthly:
        return DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          0,
        );
    }
  }

  List<Map<String, dynamic>> get _filteredRecords {
    final start = _periodStart;
    final end = _periodEnd;

    return _records.where((record) {
      final date = _parseDate(record['date']);
      if (date == null) return false;

      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  Duration _sessionDuration(Map session) {
    final checkIn = _parseTime(session['checkInTime']);
    final checkOut = _parseTime(session['checkOutTime']);

    if (checkIn == null) return Duration.zero;

    final end = checkOut ?? DateTime.now();

    if (!end.isAfter(checkIn)) return Duration.zero;

    return end.difference(checkIn);
  }

  Duration _recordDuration(Map<String, dynamic> record) {
    final sessions = record['sessions'];

    if (sessions is! List) return Duration.zero;

    var total = Duration.zero;

    for (final session in sessions) {
      if (session is Map) {
        total += _sessionDuration(session);
      }
    }

    return total;
  }

  Duration get _totalWorked {
    var total = Duration.zero;

    for (final record in _filteredRecords) {
      total += _recordDuration(record);
    }

    return total;
  }

  int get _sessionCount {
    var count = 0;

    for (final record in _filteredRecords) {
      final sessions = record['sessions'];

      if (sessions is List) {
        count += sessions.length;
      }
    }

    return count;
  }

  int get _daysAttended => _filteredRecords.where((record) {
    final sessions = record['sessions'];
    return sessions is List && sessions.isNotEmpty;
  }).length;

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return l10n.workDuration(hours, minutes);
  }

  String _formatTime(dynamic value) {
    final time = _parseTime(value);

    if (time == null) return l10n.timeUnavailable;

    return DateFormat.jm(
      Localizations.localeOf(context).toString(),
    ).format(time);
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(date);
  }

  String get _periodLabel {
    switch (_selectedPeriod) {
      case HistoryPeriod.daily:
        return _formatDate(_selectedDate);
      case HistoryPeriod.weekly:
        return '${_formatDate(_periodStart)} – '
            '${_formatDate(_periodEnd)}';
      case HistoryPeriod.monthly:
        return DateFormat.yMMMM(
          Localizations.localeOf(context).toString(),
        ).format(_selectedDate);
    }
  }

  void _changePeriod(HistoryPeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
  }

  void _movePeriod(int direction) {
    setState(() {
      switch (_selectedPeriod) {
        case HistoryPeriod.daily:
          _selectedDate = _selectedDate.add(
            Duration(days: direction),
          );
          break;
        case HistoryPeriod.weekly:
          _selectedDate = _selectedDate.add(
            Duration(days: direction * 7),
          );
          break;
        case HistoryPeriod.monthly:
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month + direction,
            1,
          );
          break;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: l10n.selectAttendanceDate,
      cancelText: l10n.cancel,
      confirmText: l10n.confirm,
    );

    if (picked == null || !mounted) return;

    setState(() {
      _selectedDate = DateUtils.dateOnly(picked);
    });
  }

  void _showSessions(Map<String, dynamic> record) {
    final sessions = record['sessions'] as List? ?? [];
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: Sizes.radiusBottomSheet,
      ),
      builder: (sheetContext) {
        final sheetL10n = AppLocalizations.of(sheetContext);

        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.85,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Sizes.p20,
                Sizes.p8,
                Sizes.p20,
                Sizes.p16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(
                      _parseDate(record['date']) ?? _selectedDate,
                    ),
                    style: theme.textTheme.titleLarge,
                  ),
                  Sizes.gapH8,
                  Text(
                    '${sheetL10n.totalWorked}: '
                        '${_formatDuration(_recordDuration(record))}',
                    style: theme.textTheme.titleMedium,
                  ),
                  Sizes.gapH16,
                  Expanded(
                    child: sessions.isEmpty
                        ? Center(
                      child: Text(
                        sheetL10n.noAttendanceSessions,
                        textAlign: TextAlign.center,
                      ),
                    )
                        : ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index] as Map;
                        final checkOut = session['checkOutTime'];

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: Sizes.p8,
                          ),
                          color: AppColors.panel,
                          shape: RoundedRectangleBorder(
                            borderRadius: Sizes.radius16,
                            side: const BorderSide(
                              color: AppColors.borderSubtle,
                            ),
                          ),
                          child: ListTile(
                            contentPadding:
                            const EdgeInsets.symmetric(
                              horizontal: Sizes.p12,
                              vertical: Sizes.p4,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.panelAlt,
                              foregroundColor: AppColors.blue,
                              child: Text('${index + 1}'),
                            ),
                            title: Text(
                              '${sheetL10n.checkIn}: '
                                  '${_formatTime(session['checkInTime'])}',
                            ),
                            subtitle: Text(
                              checkOut == null
                                  ? '${sheetL10n.checkOut}: '
                                  '${sheetL10n.inProgress}'
                                  : '${sheetL10n.checkOut}: '
                                  '${_formatTime(checkOut)}',
                            ),
                            trailing: Text(
                              _formatDuration(
                                _sessionDuration(session),
                              ),
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.attendanceHistory),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadHistory,
            tooltip: l10n.refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(Sizes.p16),
          children: [
            SegmentedButton<HistoryPeriod>(
              segments: [
                ButtonSegment(
                  value: HistoryPeriod.daily,
                  label: Text(l10n.daily),
                  icon: const Icon(Icons.today_rounded),
                ),
                ButtonSegment(
                  value: HistoryPeriod.weekly,
                  label: Text(l10n.weekly),
                  icon: const Icon(Icons.date_range_rounded),
                ),
                ButtonSegment(
                  value: HistoryPeriod.monthly,
                  label: Text(l10n.monthly),
                  icon: const Icon(Icons.calendar_month_rounded),
                ),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (selection) {
                _changePeriod(selection.first);
              },
            ),
            Sizes.gapH20,
            Card(
              color: AppColors.panel,
              shape: RoundedRectangleBorder(
                borderRadius: Sizes.radius16,
                side: const BorderSide(
                  color: AppColors.borderSubtle,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.p8,
                  vertical: Sizes.p8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _movePeriod(-1),
                      tooltip: l10n.previousPeriod,
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: Sizes.radius12,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Sizes.p10,
                            horizontal: Sizes.p4,
                          ),
                          child: Column(
                            children: [
                              Text(
                                _periodLabel,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium,
                              ),
                              Sizes.gapH4,
                              Text(
                                l10n.tapToSelectDate,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _periodEnd.isBefore(
                        DateUtils.dateOnly(DateTime.now()),
                      )
                          ? () => _movePeriod(1)
                          : null,
                      tooltip: l10n.nextPeriod,
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),
            ),
            Sizes.gapH16,
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    title: l10n.totalWorked,
                    value: _formatDuration(_totalWorked),
                    icon: Icons.schedule_rounded,
                    color: AppColors.blue,
                  ),
                ),
                Sizes.gapW12,
                Expanded(
                  child: _summaryCard(
                    title: l10n.daysAttended,
                    value: '$_daysAttended',
                    icon: Icons.event_available_rounded,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            Sizes.gapH12,
            _summaryCard(
              title: l10n.attendanceSessions,
              value: '$_sessionCount',
              icon: Icons.login_rounded,
              color: AppColors.cyan,
            ),
            Sizes.gapH24,
            Text(
              l10n.attendanceRecords,
              style: theme.textTheme.titleLarge,
            ),
            Sizes.gapH12,
            if (records.isEmpty)
              Card(
                color: AppColors.panel,
                shape: RoundedRectangleBorder(
                  borderRadius: Sizes.radius16,
                  side: const BorderSide(
                    color: AppColors.borderSubtle,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.p20,
                    vertical: Sizes.p32,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: Sizes.iconHero,
                        color: AppColors.muted,
                      ),
                      Sizes.gapH12,
                      Text(
                        l10n.noAttendanceRecords,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                      Sizes.gapH8,
                      Text(
                        l10n.noAttendanceRecordsHint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...records.map((record) {
                final sessions =
                    record['sessions'] as List? ?? [];

                if (sessions.isEmpty) {
                  return const SizedBox.shrink();
                }

                final firstSession = sessions.first as Map;
                final lastSession = sessions.last as Map;
                final lastCheckOut = lastSession['checkOutTime'];
                final date =
                    _parseDate(record['date']) ?? _selectedDate;

                return Card(
                  color: AppColors.panel,
                  margin: const EdgeInsets.only(
                    bottom: Sizes.p12,
                  ),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: Sizes.radius16,
                    side: const BorderSide(
                      color: AppColors.borderSubtle,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _showSessions(record),
                    child: Padding(
                      padding: const EdgeInsets.all(Sizes.p16),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month_rounded,
                                color: AppColors.blue,
                                size: Sizes.iconLg,
                              ),
                              Sizes.gapW10,
                              Expanded(
                                child: Text(
                                  _formatDate(date),
                                  style:
                                  theme.textTheme.titleMedium,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.muted,
                                size: Sizes.iconLg,
                              ),
                            ],
                          ),
                          Sizes.gapH16,
                          Row(
                            children: [
                              Expanded(
                                child: _timeColumn(
                                  l10n.firstCheckIn,
                                  _formatTime(
                                    firstSession['checkInTime'],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _timeColumn(
                                  l10n.lastCheckOut,
                                  lastCheckOut == null
                                      ? l10n.inProgress
                                      : _formatTime(lastCheckOut),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: Sizes.p28),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: Sizes.iconSm,
                                color: AppColors.muted,
                              ),
                              Sizes.gapW8,
                              Expanded(
                                child: Text(l10n.totalWorked),
                              ),
                              Text(
                                _formatDuration(
                                  _recordDuration(record),
                                ),
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (sessions.length > 1) ...[
                            Sizes.gapH8,
                            Text(
                              l10n.sessionCountHint(
                                sessions.length,
                              ),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      color: AppColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: Sizes.radius16,
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: Sizes.iconLg),
            Sizes.gapH12,
            Text(
              title,
              style: theme.textTheme.bodySmall,
            ),
            Sizes.gapH8,
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeColumn(String label, String value) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        Sizes.gapH8,
        Text(
          value,
          style: theme.textTheme.titleSmall,
        ),
      ],
    );
  }
}