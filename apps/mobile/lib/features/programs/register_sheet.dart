import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcf_models/jcf_models.dart';

import '../../core/launch.dart';
import 'programs_repository.dart';

Future<void> showRegisterSheet(BuildContext context, Program program) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: _RegisterSheet(program: program),
      ),
    ),
  );
}

class _RegisterSheet extends ConsumerStatefulWidget {
  const _RegisterSheet({required this.program});
  final Program program;

  @override
  ConsumerState<_RegisterSheet> createState() => _RegisterSheetState();
}

class _RegisterSheetState extends ConsumerState<_RegisterSheet> {
  int _quantity = 1;
  int? _tierId;
  final Map<String, TextEditingController> _fields = {};
  bool _busy = false;
  String? _error;

  Registration? _registration; // set after register
  bool _awaitingPayment = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    for (final f in widget.program.formSchema) {
      _fields[f.name] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  ProgramsRepository get _repo => ref.read(programsRepositoryProvider);

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final answers = {for (final e in _fields.entries) e.key: e.value.text.trim()};
      final result = await _repo.register(
        widget.program.slug,
        quantity: _quantity,
        tierId: _tierId,
        answers: answers,
      );
      _registration = result.registration;
      if (!result.requiresPayment) {
        _finish();
      } else {
        final init = await _repo.initializePayment(_registration!.reference);
        await openExternalUrl(init.authorizationUrl);
        setState(() => _awaitingPayment = true);
      }
    } catch (_) {
      setState(() => _error = 'Could not register. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    setState(() => _busy = true);
    try {
      final reg = await _repo.verify(_registration!.reference);
      _registration = reg;
      if (reg.isConfirmed) {
        _finish();
      } else {
        setState(() => _error = 'Payment not confirmed yet.');
      }
    } catch (_) {
      setState(() => _error = 'Could not verify payment yet.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _finish() {
    ref.invalidate(myRegistrationsProvider);
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: _done ? _confirmation() : _form(),
    );
  }

  Widget _confirmation() {
    final reg = _registration!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 56),
        const SizedBox(height: 12),
        Text('Registration confirmed', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('Reference: ${reg.reference}'),
        const SizedBox(height: 16),
        if (reg.qrUrl.isNotEmpty)
          Image.network(reg.qrUrl, height: 160, width: 160,
              errorBuilder: (_, _, _) => const SizedBox.shrink()),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _form() {
    final p = widget.program;
    final tiers = p.tiers.where((t) => !t.isSoldOut).toList();
    return ListView(
      shrinkWrap: true,
      children: [
        Text('Register — ${p.title}', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('People'),
            const Spacer(),
            IconButton(
              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$_quantity'),
            IconButton(
              onPressed: () => setState(() => _quantity++),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        if (tiers.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Accommodation', style: Theme.of(context).textTheme.titleSmall),
          RadioGroup<int?>(
            groupValue: _tierId,
            onChanged: (v) => setState(() => _tierId = v),
            child: Column(
              children: [
                RadioListTile<int?>(
                  value: null,
                  title: const Text('None'),
                ),
                for (final t in tiers)
                  RadioListTile<int?>(
                    value: t.id,
                    title: Text(t.name),
                    subtitle: Text('${p.currency} ${t.pricePerPerson} /person'),
                  ),
              ],
            ),
          ),
        ],
        for (final f in p.formSchema) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _fields[f.name],
            keyboardType: f.type == 'number'
                ? TextInputType.number
                : f.type == 'email'
                    ? TextInputType.emailAddress
                    : TextInputType.text,
            maxLines: f.type == 'textarea' ? 3 : 1,
            decoration: InputDecoration(
              labelText: f.label + (f.required ? ' *' : ''),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.deepOrange)),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _busy
              ? null
              : (_awaitingPayment ? _verify : _submit),
          child: _busy
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_awaitingPayment ? 'I have paid' : (p.requiresPayment ? 'Continue to payment' : 'Register')),
        ),
        if (_awaitingPayment)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Complete payment in your browser, then tap "I have paid".',
                textAlign: TextAlign.center),
          ),
      ],
    );
  }
}
