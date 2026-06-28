import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: auth.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not load profile.')),
        data: (member) {
          if (member == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sign in to access premium lessons, programs, and your activity.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.push('/login'),
                      child: const Text('Member sign in'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            children: [
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(member.fullName),
                subtitle: Text(member.email),
              ),
              if (member.centre != null)
                ListTile(
                  leading: const Icon(Icons.place),
                  title: const Text('Centre'),
                  subtitle: Text(member.centre!),
                ),
              ListTile(
                leading: const Icon(Icons.badge),
                title: const Text('Status'),
                subtitle: Text([
                  if (member.isMember) 'Member',
                  if (member.isStudent) 'Student',
                ].join(' · ')),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: () => ref.read(authControllerProvider.notifier).logout(),
              ),
            ],
          );
        },
      ),
    );
  }
}
