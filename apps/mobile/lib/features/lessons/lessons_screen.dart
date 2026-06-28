import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_models/jcf_models.dart';
import 'package:jcf_ui/jcf_ui.dart';

import 'lessons_repository.dart';

class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(lessonsListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Lessons')),
      body: lessons.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorRetry(onRetry: () => ref.invalidate(lessonsListProvider)),
        data: (page) {
          if (page.results.isEmpty) {
            return const Center(child: Text('No lessons yet.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(lessonsListProvider),
            child: ListView.separated(
              itemCount: page.results.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) => _LessonTile(lesson: page.results[i]),
            ),
          );
        },
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson});
  final Teaching lesson;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: JcfColors.heroNavy,
        child: Icon(
          lesson.mediaKind == 'audio' ? Icons.headphones : Icons.play_arrow,
          color: JcfColors.gold,
        ),
      ),
      title: Text(lesson.topic),
      subtitle: Text(lesson.format),
      trailing: lesson.isLocked
          ? const Icon(Icons.lock, size: 18, color: JcfColors.mutedText)
          : const Icon(Icons.chevron_right),
      onTap: () => context.push('/lessons/${lesson.slug}'),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Couldn't load lessons."),
          const SizedBox(height: 8),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
