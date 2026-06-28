import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcf_models/jcf_models.dart';

import '../../core/launch.dart';
import '../auth/auth_controller.dart';
import 'donations_repository.dart';

Future<void> showDonateSheet(BuildContext context, Cause cause) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _DonateSheet(cause: cause),
    ),
  );
}

class _DonateSheet extends ConsumerStatefulWidget {
  const _DonateSheet({required this.cause});
  final Cause cause;

  @override
  ConsumerState<_DonateSheet> createState() => _DonateSheetState();
}

class _DonateSheetState extends ConsumerState<_DonateSheet> {
  final _amount = TextEditingController();
  final _email = TextEditingController();
  String? _reference;
  bool _busy = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    _email.text = ref.read(authControllerProvider).asData?.value?.email ?? '';
  }

  @override
  void dispose() {
    _amount.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final amount = num.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0 || _email.text.trim().isEmpty) {
      setState(() => _status = 'Enter a valid amount and email.');
      return;
    }
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final init = await ref.read(donationsRepositoryProvider).initialize(
            amount: amount,
            email: _email.text.trim(),
            causeId: widget.cause.id,
          );
      _reference = init.reference;
      await openExternalUrl(init.authorizationUrl);
      setState(() => _status = 'Complete payment in your browser, then tap "I have paid".');
    } catch (_) {
      setState(() => _status = 'Could not start payment. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    if (_reference == null) return;
    setState(() => _busy = true);
    try {
      final ok = await ref.read(donationsRepositoryProvider).verify(
            reference: _reference!,
            causeId: widget.cause.id,
          );
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your donation!')),
        );
      } else {
        setState(() => _status = 'Payment not confirmed yet.');
      }
    } catch (_) {
      setState(() => _status = 'Could not verify payment yet.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Donate to ${widget.cause.title}',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount (${widget.cause.currency})',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email for receipt',
              border: OutlineInputBorder(),
            ),
          ),
          if (_status != null) ...[
            const SizedBox(height: 12),
            Text(_status!, style: const TextStyle(color: Colors.deepOrange)),
          ],
          const SizedBox(height: 16),
          if (_reference == null)
            FilledButton(
              onPressed: _busy ? null : _start,
              child: _busy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Continue to payment'),
            )
          else
            FilledButton(
              onPressed: _busy ? null : _verify,
              child: const Text('I have paid'),
            ),
        ],
      ),
    );
  }
}
