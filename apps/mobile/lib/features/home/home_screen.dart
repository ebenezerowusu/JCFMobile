import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../engagement/engagement_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(authControllerProvider).asData?.value;
    final announcements = ref.watch(announcementsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('JCF'),
        actions: [
          if (member != null)
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () => context.push('/notifications'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(announcementsProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              member == null ? 'Welcome' : 'Welcome, ${member.fullName.split(' ').first}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              member == null
                  ? 'Explore lessons and the foundation. Sign in to unlock more.'
                  : 'Jan Cosmic Foundation',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text('Announcements', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            announcements.when(
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
              error: (_, _) => const Text('Could not load announcements.'),
              data: (page) => page.results.isEmpty
                  ? const Text('No announcements yet.')
                  : Column(
                      children: [
                        for (final a in page.results.take(5))
                          Card(
                            child: ListTile(
                              leading: a.pinned ? const Icon(Icons.push_pin) : const Icon(Icons.campaign),
                              title: Text(a.title),
                              subtitle: Text(a.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            if (member != null)
              OutlinedButton.icon(
                onPressed: () => context.push('/appointments'),
                icon: const Icon(Icons.event),
                label: const Text('My appointments'),
              ),
          ],
        ),
      ),
    );
  }
}
