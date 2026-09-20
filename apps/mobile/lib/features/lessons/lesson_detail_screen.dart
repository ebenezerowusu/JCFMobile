import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/launch.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';
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
              if (l.author.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(l.author,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
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
              if (ref.watch(isLoggedInProvider)) ...[
                const SizedBox(height: 24),
                _MarkCompleteButton(slug: slug),
              ],
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


/// "Mark as complete" — the member's explicit completion action until the
/// in-app player reports playback progress (design 26).
class _MarkCompleteButton extends ConsumerStatefulWidget {
  const _MarkCompleteButton({required this.slug});

  final String slug;

  @override
  ConsumerState<_MarkCompleteButton> createState() =>
      _MarkCompleteButtonState();
}

class _MarkCompleteButtonState extends ConsumerState<_MarkCompleteButton> {
  bool _busy = false;
  bool _done = false;

  Future<void> _complete() async {
    setState(() => _busy = true);
    try {
      await ref.read(lessonsRepositoryProvider).markCompleted(widget.slug);
      ref.invalidate(continueLearningProvider);
      if (mounted) setState(() => _done = true);
    } catch (_) {
      // leave the button available to retry
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (_done) {
      return Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF2E9E5B)),
          const SizedBox(width: 8),
          Text(t.completedLabel,
              style: const TextStyle(
                color: Color(0xFF2E9E5B),
                fontWeight: FontWeight.w700,
              )),
        ],
      );
    }
    return OutlinedButton.icon(
      onPressed: _busy ? null : _complete,
      icon: const Icon(Icons.check_rounded),
      label: Text(t.markComplete),
    );
  }
}
