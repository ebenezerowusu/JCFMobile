import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';
import 'live_models.dart';

const _sub = Color(0xFF667085);
const _ink = Color(0xFF172033);
const _divider = Color(0xFFE4E7EC);

/// Keep memory bounded during a long session.
const _maxRetained = 200;

/// Live chat.
///
/// Transport note: the backend has no socket layer yet, so this polls with
/// a cursor. Everything above [_LiveChatTransport] is transport-agnostic —
/// swapping in a Channels consumer means replacing this one class.
class LiveChatPanel extends ConsumerStatefulWidget {
  const LiveChatPanel(
      {super.key, required this.eventId, required this.config});

  final int eventId;
  final LiveChatConfig config;

  @override
  ConsumerState<LiveChatPanel> createState() => _LiveChatPanelState();
}

class _LiveChatPanelState extends ConsumerState<LiveChatPanel> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <LiveChatMessage>[];
  LiveChatMessage? _pinned;
  Timer? _poll;
  int? _cursor;
  bool _forbidden = false;
  bool _sending = false;
  DateTime? _lastSentAt;

  @override
  void initState() {
    super.initState();
    if (widget.config.enabled) {
      _refresh();
      // Chat connects independently of playback.
      _poll = Timer.periodic(
          const Duration(seconds: 5), (_) => _refresh(incremental: true));
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _refresh({bool incremental = false}) async {
    try {
      final page = await ref
          .read(liveRepositoryProvider)
          .chat(widget.eventId, after: incremental ? _cursor : null);
      if (!mounted) return;
      setState(() {
        _forbidden = false;
        _pinned = page.pinned;
        if (incremental) {
          _messages.addAll(page.messages);
        } else {
          _messages
            ..clear()
            ..addAll(page.messages);
        }
        // Drop a pending copy once the server returns the real message.
        _messages.removeWhere((m) => m.pending &&
            page.messages.any((s) => s.text == m.text));
        if (_messages.length > _maxRetained) {
          _messages.removeRange(0, _messages.length - _maxRetained);
        }
        if (_messages.isNotEmpty) {
          _cursor = _messages
              .where((m) => !m.pending)
              .fold<int?>(_cursor, (acc, m) => m.id > (acc ?? 0) ? m.id : acc);
        }
      });
      if (page.messages.isNotEmpty) _scrollToEnd();
    } on LiveChatForbidden {
      if (mounted) setState(() => _forbidden = true);
    } catch (_) {
      // A dropped poll is not worth interrupting the viewer.
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> _send() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;

    if (!ref.read(isLoggedInProvider)) {
      messenger.showSnackBar(SnackBar(
        content: Text(t.signInToParticipate),
        action: SnackBarAction(
            label: t.signIn, onPressed: () => context.push('/login')),
      ));
      return;
    }

    // Local slow-mode guard; the server enforces the real one.
    final slow = Duration(seconds: widget.config.slowModeSeconds);
    if (_lastSentAt != null && slow > Duration.zero) {
      final waited = DateTime.now().difference(_lastSentAt!);
      if (waited < slow) {
        messenger.showSnackBar(SnackBar(
            content: Text(t.slowModeOn((slow - waited).inSeconds + 1))));
        return;
      }
    }

    final optimistic = LiveChatMessage(
      id: -DateTime.now().millisecondsSinceEpoch,
      displayName: '',
      role: 'participant',
      text: text,
      deleted: false,
      pinned: false,
      createdAt: DateTime.now(),
      pending: true,
    );
    setState(() {
      _messages.add(optimistic);
      _sending = true;
      _input.clear();
    });
    _scrollToEnd();

    try {
      final sent =
          await ref.read(liveRepositoryProvider).send(widget.eventId, text);
      if (!mounted) return;
      setState(() {
        final index = _messages.indexOf(optimistic);
        if (index >= 0) _messages[index] = sent;
        _cursor = sent.id > (_cursor ?? 0) ? sent.id : _cursor;
        _lastSentAt = DateTime.now();
      });
    } on DioException catch (error) {
      if (!mounted) return;
      final retry = error.response?.data is Map
          ? (error.response!.data as Map)['retry_after']
          : null;
      setState(() {
        final index = _messages.indexOf(optimistic);
        if (index >= 0) {
          _messages[index] = LiveChatMessage(
            id: optimistic.id,
            displayName: optimistic.displayName,
            role: optimistic.role,
            text: optimistic.text,
            deleted: false,
            pinned: false,
            createdAt: optimistic.createdAt,
            failed: true,
          );
        }
      });
      messenger.showSnackBar(SnackBar(
        content: Text(retry is int ? t.slowModeOn(retry) : t.genericError),
      ));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _report(LiveChatMessage message) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(liveRepositoryProvider).report(widget.eventId, message.id);
      messenger.showSnackBar(SnackBar(content: Text(t.messageReported)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.genericError)));
    }
  }

  Future<void> _block(LiveChatMessage message) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final contactId = message.contactId;
    if (contactId == null) return;
    try {
      await ref.read(liveRepositoryProvider).block(widget.eventId, contactId);
      if (!mounted) return;
      setState(() => _messages.removeWhere((m) => m.contactId == contactId));
      messenger.showSnackBar(SnackBar(content: Text(t.userBlocked)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.genericError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final loggedIn = ref.watch(isLoggedInProvider);

    if (!widget.config.enabled) {
      return _Notice(text: t.chatClosed);
    }
    if (_forbidden || (!loggedIn && !widget.config.visibleToGuests)) {
      return _Notice(text: t.signInToParticipate, showSignIn: true);
    }

    return Column(
      children: [
        if (_pinned case final pinned?)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: const Color(0xFFEAF2FF),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.push_pin_rounded,
                    size: 15, color: JcfColors.skyPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pinned.text,
                    style: const TextStyle(
                      color: _ink,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Text(
                    t.joinTheConversation,
                    style: const TextStyle(
                      color: _sub,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 13.5,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, i) => _MessageTile(
                    message: _messages[i],
                    onReport: () => _report(_messages[i]),
                    onBlock: () => _block(_messages[i]),
                  ),
                ),
        ),
        const Divider(height: 1, color: _divider),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: widget.config.readOnly
                ? Text(
                    t.chatReadOnly,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _sub,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 13,
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          maxLength: widget.config.maxMessageLength,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: loggedIn
                                ? t.joinTheConversation
                                : t.signInToParticipate,
                            counterText: '',
                            isDense: true,
                            filled: true,
                            fillColor: const Color(0xFFF8F8F5),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        button: true,
                        label: t.shareLabel,
                        child: IconButton.filled(
                          onPressed: _sending ? null : _send,
                          icon: const Icon(Icons.send_rounded, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: JcfColors.skyPrimary,
                            minimumSize: const Size(48, 48),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile(
      {required this.message, required this.onReport, required this.onBlock});

  final LiveChatMessage message;
  final VoidCallback onReport;
  final VoidCallback onBlock;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final isStaff =
        message.role == 'moderator' || message.role == 'facilitator';

    if (message.deleted) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          '— ${t.messageReported}',
          style: const TextStyle(
            color: _sub,
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Opacity(
        opacity: message.pending ? 0.6 : 1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor:
                  isStaff ? JcfColors.skyPrimary : const Color(0xFFEAF2FF),
              child: Text(
                message.displayName.isEmpty
                    ? '·'
                    : message.displayName.characters.first.toUpperCase(),
                style: TextStyle(
                  color: isStaff ? Colors.white : JcfColors.skyPrimary,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          message.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ink,
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (isStaff) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            message.role.toUpperCase(),
                            style: const TextStyle(
                              color: JcfColors.skyPrimary,
                              fontFamily: JcfTypography.bodyFamily,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Text(
                        DateFormat.jm(locale).format(message.createdAt),
                        style: const TextStyle(
                            color: _sub,
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 10.5),
                      ),
                      if (message.failed) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.error_outline_rounded,
                            size: 12, color: Color(0xFFF04438)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.text,
                    style: const TextStyle(
                      color: _ink,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (!message.pending)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded,
                    size: 16, color: _sub),
                onSelected: (value) =>
                    value == 'report' ? onReport() : onBlock(),
                itemBuilder: (context) => [
                  PopupMenuItem(
                      value: 'report', child: Text(t.reportMessage)),
                  if (message.contactId != null)
                    PopupMenuItem(value: 'block', child: Text(t.blockUser)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, this.showSignIn = false});

  final String text;
  final bool showSignIn;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.forum_outlined, size: 30, color: _sub),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _sub,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 13.5,
              ),
            ),
            if (showSignIn) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.push('/login'),
                child: Text(t.signIn),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
