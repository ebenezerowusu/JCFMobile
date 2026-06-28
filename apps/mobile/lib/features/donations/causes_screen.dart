import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcf_models/jcf_models.dart';

import 'donate_sheet.dart';
import 'donations_repository.dart';

class CausesScreen extends ConsumerWidget {
  const CausesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final causes = ref.watch(causesListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Give')),
      body: causes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(causesListProvider),
            child: const Text('Retry'),
          ),
        ),
        data: (page) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(causesListProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final c in page.results) _CauseCard(cause: c),
              if (page.results.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 64),
                  child: Center(child: Text('No causes right now.')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CauseCard extends StatelessWidget {
  const _CauseCard({required this.cause});
  final Cause cause;

  @override
  Widget build(BuildContext context) {
    final specific = cause.type == 'specific' && cause.goalAmount > 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cause.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(cause.description, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            if (specific) ...[
              LinearProgressIndicator(value: cause.progressPercent / 100),
              const SizedBox(height: 6),
              Text(
                '${cause.currency} ${cause.raisedAmount} raised of ${cause.goalAmount} (${cause.progressPercent}%)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else if (cause.impactStatement.isNotEmpty)
              Text(cause.impactStatement, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => showDonateSheet(context, cause),
                child: const Text('Donate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
