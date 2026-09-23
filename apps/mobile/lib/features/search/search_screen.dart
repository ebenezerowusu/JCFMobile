import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import 'search_repository.dart';

const _sub = Color(0xFF54689B);

(IconData, Color, Color) _kindLook(String kind) => switch (kind) {
      'video' => (Icons.play_circle_fill_rounded, JcfColors.skyPrimary,
          const Color(0xFFE3EEFF)),
      'audio' => (Icons.headphones_rounded, const Color(0xFF7B5BD6),
          const Color(0xFFEAE3FA)),
      'practice' => (Icons.self_improvement_rounded, const Color(0xFF2E9E5B),
          const Color(0xFFDDF3E4)),
      'programme' => (Icons.school_rounded, const Color(0xFFF08A24),
          const Color(0xFFFDEED9)),
      'event' => (Icons.calendar_month_rounded, const Color(0xFF7B5BD6),
          const Color(0xFFEAE3FA)),
      'centre' => (Icons.location_on_rounded, const Color(0xFF19A7CE),
          const Color(0xFFDFF3F9)),
      _ => (Icons.campaign_rounded, const Color(0xFF2EBFA5),
          const Color(0xFFDDF6F1)),
    };

/// Global search (designs 30/31): browse state with recent, categories and
/// popular searches; typed state with filterable cross-domain results.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String _filter = 'all';
  List<SearchResult>? _results;
  List<String> _recent = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    ref.read(recentSearchStoreProvider).load().then((items) {
      if (mounted) setState(() => _recent = items);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () => _run(value));
  }

  Future<void> _run(String value) async {
    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _query = query;
        _results = null;
        _loading = false;
      });
      return;
    }
    setState(() {
      _query = query;
      _loading = true;
    });
    try {
      final results = await ref.read(searchRepositoryProvider).search(query);
      final recent = await ref.read(recentSearchStoreProvider).add(query);
      if (!mounted || _query != query) return;
      setState(() {
        _results = results;
        _recent = recent;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _search(String term) {
    _controller.text = term;
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    _run(term);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final showResults = _query.length >= 2;

    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      appBar: AppBar(
        backgroundColor: JcfColors.skySurface,
        elevation: 0,
        foregroundColor: JcfColors.inkOnLight,
        title: Text(
          t.searchJcfTitle,
          style: const TextStyle(
            color: JcfColors.inkOnLight,
            fontFamily: JcfTypography.bodyFamily,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: _run,
              style: const TextStyle(
                color: JcfColors.inkOnLight,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 15.5,
              ),
              decoration: InputDecoration(
                hintText: t.searchHint,
                hintStyle: const TextStyle(color: _sub, fontSize: 15),
                prefixIcon: const Icon(Icons.search_rounded, color: _sub),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: _sub, size: 20),
                        onPressed: () {
                          _controller.clear();
                          _run('');
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide:
                      const BorderSide(color: JcfColors.skyPrimary, width: 1.4),
                ),
              ),
            ),
          ),
          Expanded(
            child: showResults ? _buildResults(t) : _buildBrowse(t),
          ),
        ],
      ),
    );
  }

  // --- Browse state (design 30) ---

  Widget _buildBrowse(AppLocalizations t) {
    final popular = ref.watch(popularSearchesProvider).asData?.value ?? const [];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      children: [
        if (_recent.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(t.recentSearches, style: _sectionStyle),
              ),
              TextButton(
                onPressed: () async {
                  await ref.read(recentSearchStoreProvider).clear();
                  setState(() => _recent = const []);
                },
                child: Text(
                  t.clearLabel,
                  style: const TextStyle(
                    color: JcfColors.skyPrimary,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final term in _recent.take(6))
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _search(term),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 16, color: JcfColors.skyPrimary),
                        const SizedBox(width: 6),
                        Text(
                          term,
                          style: const TextStyle(
                            color: JcfColors.inkOnLight,
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        Text(t.browseByCategory, style: _sectionStyle),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.05,
          children: [
            _CategoryCard(
                icon: Icons.menu_book_rounded,
                tint: JcfColors.skyPrimary,
                bg: const Color(0xFFE3EEFF),
                label: t.categoryTeachings,
                onTap: () => context.go('/lessons')),
            _CategoryCard(
                icon: Icons.self_improvement_rounded,
                tint: const Color(0xFF2E9E5B),
                bg: const Color(0xFFDDF3E4),
                label: t.categoryPractices,
                onTap: () => context.go('/practice')),
            _CategoryCard(
                icon: Icons.groups_rounded,
                tint: const Color(0xFFF08A24),
                bg: const Color(0xFFFDEED9),
                label: t.categoryProgrammes,
                onTap: () => context.go('/programs')),
            _CategoryCard(
                icon: Icons.calendar_month_rounded,
                tint: const Color(0xFF7B5BD6),
                bg: const Color(0xFFEAE3FA),
                label: t.categoryEvents,
                onTap: () => context.push('/activities')),
            _CategoryCard(
                icon: Icons.location_on_rounded,
                tint: const Color(0xFF19A7CE),
                bg: const Color(0xFFDFF3F9),
                label: t.categoryCentres,
                onTap: () => _search(t.categoryCentres.toLowerCase())),
            _CategoryCard(
                icon: Icons.campaign_rounded,
                tint: const Color(0xFF2EBFA5),
                bg: const Color(0xFFDDF6F1),
                label: t.announcementsTitle,
                onTap: () => context.push('/announcements')),
          ],
        ),
        if (popular.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(t.popularSearches, style: _sectionStyle),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                for (var i = 0; i < popular.length; i++) ...[
                  if (i > 0)
                    const Divider(
                        height: 1,
                        indent: 58,
                        color: Color(0xFFE7EEFA)),
                  InkWell(
                    onTap: () => _search(popular[i]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: const Color(0xFFE3EEFF),
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                color: JcfColors.skyPrimary,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _titleCase(popular[i]),
                              style: const TextStyle(
                                color: JcfColors.inkOnLight,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: _sub, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  // --- Results state (design 31) ---

  Widget _buildResults(AppLocalizations t) {
    if (_loading && _results == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final all = _results ?? const <SearchResult>[];
    final visible = all.where((r) => switch (_filter) {
          'teachings' => r.kind == 'video' || r.kind == 'audio',
          'practices' => r.kind == 'practice',
          'programmes' => r.kind == 'programme',
          'events' => r.kind == 'event',
          'centres' => r.kind == 'centre',
          'announcements' => r.kind == 'announcement',
          _ => true,
        }).toList();

    final chips = [
      ('all', t.filterAll),
      ('teachings', t.categoryTeachings),
      ('practices', t.categoryPractices),
      ('programmes', t.categoryProgrammes),
      ('events', t.categoryEvents),
      ('centres', t.categoryCentres),
      ('announcements', t.announcementsTitle),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            t.resultsFor(all.length, _query),
            style: const TextStyle(
              color: JcfColors.inkOnLight,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              for (final (key, label) in chips)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _filter == key
                            ? JcfColors.skyPrimary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: _filter == key
                              ? Colors.white
                              : JcfColors.inkOnLight,
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 13.5,
                          fontWeight: _filter == key
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      t.noResults(_query),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _sub,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 15,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      _ResultCard(result: visible[i]),
                ),
        ),
      ],
    );
  }

  static const _sectionStyle = TextStyle(
    color: JcfColors.inkOnLight,
    fontFamily: JcfTypography.bodyFamily,
    fontSize: 18.5,
    fontWeight: FontWeight.w800,
  );

  static String _titleCase(String term) => term
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard(
      {required this.icon, required this.tint, required this.bg,
      required this.label, required this.onTap});

  final IconData icon;
  final Color tint;
  final Color bg;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: tint, size: 34),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: JcfColors.inkOnLight,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 15, color: _sub),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends ConsumerWidget {
  const _ResultCard({required this.result});

  final SearchResult result;

  String _kindLabel(AppLocalizations t) => switch (result.kind) {
        'video' => t.kindVideo,
        'audio' => t.kindAudio,
        'practice' => t.kindPractice,
        'programme' => t.kindProgramme,
        'event' => t.kindEvent,
        'centre' => t.kindCentre,
        _ => t.kindAnnouncement,
      };

  (String, Color, Color) _audienceLook(AppLocalizations t) =>
      switch (result.audience) {
        'members' => (t.audienceMembers, const Color(0xFF7B5BD6),
            const Color(0xFFEAE3FA)),
        'students' => (t.audienceStudents, const Color(0xFFF08A24),
            const Color(0xFFFDEED9)),
        _ => (t.allLevelsChip, JcfColors.skyPrimary,
            const Color(0xFFE3EEFF)),
      };

  String _metaLine(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final parts = <String>[];
    final date = result.date == null ? null : DateTime.tryParse(result.date!);
    if (date != null) parts.add(DateFormat('d MMM yyyy', locale).format(date));
    final seconds = result.durationSeconds;
    if (seconds != null && seconds > 0) {
      parts.add('${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}');
    }
    if (result.minutes != null) parts.add('${result.minutes} min');
    if (result.views != null && result.views! > 0) parts.add('${result.views}');
    if (result.subtitle.isNotEmpty && result.kind == 'centre') {
      parts.insert(0, result.subtitle);
    }
    return parts.join('  ·  ');
  }

  void _open(BuildContext context) {
    switch (result.kind) {
      case 'video' || 'audio':
        context.push('/lessons/${result.slug}');
      case 'practice':
        context.go('/practice');
      case 'programme':
        context.push('/programs/${result.slug}');
      case 'event':
        context.push('/activities');
      case 'announcement':
        context.push('/announcements');
      case 'centre':
        showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          backgroundColor: Colors.white,
          builder: (_) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.title,
                    style: const TextStyle(
                      color: JcfColors.inkOnLight,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 4),
                Text(result.subtitle,
                    style: const TextStyle(
                        color: _sub,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 14)),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(result.description,
                        style: const TextStyle(
                            color: _sub,
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 15,
                            height: 1.45)),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final (icon, tint, bg) = _kindLook(result.kind);
    final (audienceLabel, audienceTint, audienceBg) = _audienceLook(t);
    final meta = _metaLine(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: result.thumbnailUrl.isEmpty
                    ? Container(
                        width: 84,
                        height: 84,
                        color: bg,
                        child: Icon(icon, color: tint, size: 36),
                      )
                    : Image.network(
                        result.thumbnailUrl,
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 84,
                          height: 84,
                          color: bg,
                          child: Icon(icon, color: tint, size: 36),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 14, color: tint),
                        const SizedBox(width: 5),
                        Text(
                          _kindLabel(t).toUpperCase(),
                          style: TextStyle(
                            color: tint,
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 10.5,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        if (result.locked)
                          const Icon(Icons.lock_rounded,
                              size: 15, color: Color(0xFFE8B33B)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: JcfColors.inkOnLight,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 15.5,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (result.subtitle.isNotEmpty &&
                        result.kind != 'centre') ...[
                      const SizedBox(height: 2),
                      Text(
                        result.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: _sub,
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 12.5),
                      ),
                    ],
                    if (result.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        result.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _sub,
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        if (meta.isNotEmpty)
                          Expanded(
                            child: Text(
                              meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: _sub,
                                  fontFamily: JcfTypography.bodyFamily,
                                  fontSize: 11.5),
                            ),
                          )
                        else
                          const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: audienceBg,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Text(
                            audienceLabel,
                            style: TextStyle(
                              color: audienceTint,
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _sub, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
