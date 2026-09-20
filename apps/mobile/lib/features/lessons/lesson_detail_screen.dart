import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/launch.dart';
import 'lessons_repository.dart';
import 'premium_gate.dart';

class LessonDetailScreen extends ConsumerWidget {
  const LessonDetailScreen({super.key, required this.slug});
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ref.watch(lessonDetailProvider(slug));
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: lesson.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          final locked = e is DioException && e.response?.statusCode == 403;
          if (!locked) {
            return const Center(child: Text("Couldn't load this lesson."));
          }
          // Premium gate (design/14); refetch once signed in to unlock.
          return PremiumGate(
            onSignedIn: () => ref.invalidate(lessonDetailProvider(slug)),
          );
        },
        data: (l) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.topic, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                Chip(label: Text(l.format)),
                Chip(label: Text(l.language)),
                if (l.isPremium) const Chip(label: Text('Premium')),
              ]),
              const SizedBox(height: 16),
              if (l.youtubeUrl.isNotEmpty)
                _MediaRow(icon: Icons.ondemand_video, label: 'Watch on YouTube', url: l.youtubeUrl),
              if (l.mediaUrl.isNotEmpty)
                _MediaRow(icon: Icons.play_circle, label: 'Play media', url: l.mediaUrl),
              const SizedBox(height: 16),
              Text(l.description),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaRow extends StatelessWidget {
  const _MediaRow({required this.icon, required this.label, required this.url});
  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => openExternalUrl(url),
    );
  }
}
