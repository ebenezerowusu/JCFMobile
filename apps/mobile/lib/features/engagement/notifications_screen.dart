import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'engagement_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not load notifications.')),
        data: (page) {
          if (page.results.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }
          return ListView.separated(
            itemCount: page.results.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final n = page.results[i];
              return ListTile(
                leading: Icon(
                  n.isRead ? Icons.notifications_none : Icons.notifications_active,
                  color: n.isRead ? null : Theme.of(context).colorScheme.secondary,
                ),
                title: Text(n.title),
                subtitle: Text(n.body),
                onTap: n.isRead
                    ? null
                    : () async {
                        await ref.read(engagementRepositoryProvider).markRead(n.id);
                        ref.invalidate(notificationsProvider);
                      },
              );
            },
          );
        },
      ),
    );
  }
}
