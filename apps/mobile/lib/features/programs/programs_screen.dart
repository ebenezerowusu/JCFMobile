import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_models/jcf_models.dart';

import 'programs_repository.dart';

class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programs = ref.watch(programsListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Programs')),
      body: programs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(programsListProvider),
            child: const Text('Retry'),
          ),
        ),
        data: (page) {
          if (page.results.isEmpty) {
            return const Center(child: Text('No programs available.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(programsListProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [for (final p in page.results) _ProgramCard(program: p)],
            ),
          );
        },
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program});
  final Program program;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text('${program.title} (${program.year})'),
        subtitle: Text([
          if (program.venue.isNotEmpty) program.venue,
          if (program.audience != 'public') 'Members only',
        ].join(' · ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/programs/${program.slug}'),
      ),
    );
  }
}
