import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'engagement_repository.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appts = ref.watch(appointmentsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _book(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Book'),
      ),
      body: appts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not load appointments.')),
        data: (page) {
          if (page.results.isEmpty) {
            return const Center(child: Text('No appointments yet.'));
          }
          return ListView(
            children: [
              for (final a in page.results)
                ListTile(
                  leading: const Icon(Icons.event),
                  title: Text('${a.mode} — ${a.scheduledDate}'),
                  subtitle: Text(a.status),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _book(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<_BookingData>(
      context: context,
      builder: (_) => const _BookDialog(),
    );
    if (result == null) return;
    await ref.read(engagementRepositoryProvider).bookAppointment(
          mode: result.mode,
          scheduledDate: result.date,
          note: result.note,
        );
    ref.invalidate(appointmentsProvider);
  }
}

class _BookingData {
  const _BookingData(this.mode, this.date, this.note);
  final String mode;
  final String date;
  final String note;
}

class _BookDialog extends StatefulWidget {
  const _BookDialog();

  @override
  State<_BookDialog> createState() => _BookDialogState();
}

class _BookDialogState extends State<_BookDialog> {
  String _mode = 'Remote';
  DateTime? _date;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Book appointment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _mode,
            items: const [
              DropdownMenuItem(value: 'Remote', child: Text('Remote')),
              DropdownMenuItem(value: 'Onsite', child: Text('Onsite')),
            ],
            onChanged: (v) => setState(() => _mode = v ?? 'Remote'),
            decoration: const InputDecoration(labelText: 'Mode'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(_date == null
                    ? 'No date chosen'
                    : '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}'),
              ),
              TextButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: now,
                    lastDate: DateTime(now.year + 1),
                    initialDate: now,
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: const Text('Pick date'),
              ),
            ],
          ),
          TextField(
            controller: _note,
            decoration: const InputDecoration(labelText: 'Reason (optional)'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _date == null
              ? null
              : () {
                  final d = _date!;
                  final iso =
                      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                  Navigator.pop(context, _BookingData(_mode, iso, _note.text.trim()));
                },
          child: const Text('Book'),
        ),
      ],
    );
  }
}
