import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';

/// Two-step email/phone OTP login.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifier = TextEditingController();
  final _code = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendCode() => _run(() async {
        await ref.read(authControllerProvider.notifier).requestCode(_identifier.text.trim());
        if (mounted) setState(() => _codeSent = true);
      });

  Future<void> _verify() => _run(() async {
        await ref.read(authControllerProvider.notifier).verify(
              _identifier.text.trim(),
              _code.text.trim(),
            );
        final loggedIn = ref.read(isLoggedInProvider);
        if (!loggedIn) {
          setState(() => _error = 'Invalid or expired code.');
        } else if (mounted) {
          Navigator.of(context).maybePop();
        }
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member sign in')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sign in with the email or phone on your JCF membership record.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _identifier,
              enabled: !_codeSent,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email or phone',
                border: OutlineInputBorder(),
              ),
            ),
            if (_codeSent) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '6-digit code (sent to your email)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : (_codeSent ? _verify : _sendCode),
              child: _busy
                  ? const SizedBox(
                      height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_codeSent ? 'Verify & sign in' : 'Send code'),
            ),
            if (_codeSent)
              TextButton(
                onPressed: _busy ? null : () => setState(() => _codeSent = false),
                child: const Text('Use a different email/phone'),
              ),
          ],
        ),
      ),
    );
  }
}
