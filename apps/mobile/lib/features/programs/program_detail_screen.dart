import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_models/jcf_models.dart';

import '../auth/auth_controller.dart';
import 'programs_repository.dart';
import 'register_sheet.dart';

class ProgramDetailScreen extends ConsumerWidget {
  const ProgramDetailScreen({super.key, required this.slug});
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(programDetailProvider(slug));
    return Scaffold(
      appBar: AppBar(title: const Text('Program')),
      body: program.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          final forbidden = e is DioException && e.response?.statusCode == 403;
          return Center(
            child: Text(forbidden
                ? 'This program is for registered members or students.'
                : "Couldn't load this program."),
          );
        },
        data: (p) => _Detail(program: p),
      ),
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.program});
  final Program program;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedIn = ref.watch(isLoggedInProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${program.title} (${program.year})',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          if (program.venue.isNotEmpty) Text('Venue: ${program.venue}'),
          if (program.startsOn != null)
            Text('Dates: ${program.startsOn} – ${program.endsOn ?? ''}'),
          const SizedBox(height: 16),
          Text(program.description),
          if (program.costLineItems.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Fees', style: Theme.of(context).textTheme.titleMedium),
            for (final item in program.costLineItems)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(item.label),
                trailing: Text('${program.currency} ${item.amount}'
                    '${item.unit == 'per_person' ? ' /person' : ''}'),
              ),
          ],
          if (program.tiers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Accommodation', style: Theme.of(context).textTheme.titleMedium),
            for (final t in program.tiers)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(t.name),
                subtitle: t.isSoldOut ? const Text('Sold out') : Text('${t.roomsAvailable} rooms left'),
                trailing: Text('${program.currency} ${t.pricePerPerson} /person'),
              ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: !program.registrationOpen
                  ? null
                  : () {
                      if (!loggedIn) {
                        context.push('/login');
                        return;
                      }
                      showRegisterSheet(context, program);
                    },
              child: Text(program.registrationOpen ? 'Register' : 'Registration closed'),
            ),
          ),
        ],
      ),
    );
  }
}
