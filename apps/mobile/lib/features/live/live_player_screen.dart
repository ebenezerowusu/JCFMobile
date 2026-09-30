import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcf_ui/jcf_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../home/member_home_widgets.dart' show MemberImage;
import 'live_chat_panel.dart';
import 'live_models.dart';
import 'live_playback_controller.dart';

const _sub = Color(0xFF667085);
const _ink = Color(0xFF172033);
const _liveRed = Color(0xFFF04438);
const _divider = Color(0xFFE4E7EC);
const _assets = 'assets/images/live_now_player';

/// Builds the playback engine. Overridden in tests with an inert one.
final livePlaybackControllerFactoryProvider =
    Provider<LivePlaybackController Function()>(
        (ref) => VideoPlayerPlaybackController.new);

/// Live Now: a focused player route with no bottom navigation.
class LivePlayerScreen extends ConsumerStatefulWidget {
  const LivePlayerScreen({super.key, required this.eventId});

  final int eventId;

  @override
  ConsumerState<LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends ConsumerState<LivePlayerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  LivePlaybackController? _player;
  TabController? _tabs;

  /// Identifies this device's viewer session; sent only once playback runs.
  late final String _viewerKey =
      '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}';
  Timer? _heartbeat;
  Timer? _statusPoll;
  bool _viewerSessionOpen = false;
  bool _controlsVisible = true;
  Timer? _hideControls;
  String? _initializedUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeat?.cancel();
    _statusPoll?.cancel();
    _hideControls?.cancel();
    _endViewerSession();
    _player?.dispose();
    _tabs?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // No background audio for a session the viewer stepped away from.
    if (state == AppLifecycleState.paused) {
      _player?.pause();
    } else if (state == AppLifecycleState.resumed) {
      // Reconcile status rather than assuming the stream is still running.
      ref.invalidate(liveEventProvider(widget.eventId));
    }
  }

  // --- status polling & countdown -------------------------------------

  /// Backs off when the event is far away and tightens near start time,
  /// so the server is not polled needlessly.
  Duration _pollInterval(LiveEventDetail event) {
    final until = event.startsAt.difference(DateTime.now());
    if (until > const Duration(minutes: 15)) return const Duration(minutes: 5);
    if (until > Duration.zero) return const Duration(seconds: 45);
    return const Duration(seconds: 15);
  }

  void _syncTimers(LiveEventDetail event) {
    final wanted = event.status.isBeforeStart;
    if (wanted == (_statusPoll?.isActive ?? false)) return;
    _statusPoll?.cancel();
    if (!wanted) return;
    // Only the status poll lives here. The countdown ticks inside its own
    // widget so a second passing never rebuilds the player.
    _statusPoll = Timer.periodic(_pollInterval(event), (_) {
      if (mounted) ref.invalidate(liveEventProvider(widget.eventId));
    });
  }

  // --- playback --------------------------------------------------------

  Future<void> _ensurePlayer(LiveEventDetail event) async {
    final url = event.playableUrl;
    if (url == null || url.isEmpty || url == _initializedUrl) return;
    _initializedUrl = url;
    final player = ref.read(livePlaybackControllerFactoryProvider)();
    _player?.dispose();
    _player = player;
    player.addListener(_onPlayback);
    await player.initialize(url);
    if (!mounted) return;
    setState(() {});
  }

  void _onPlayback() {
    final player = _player;
    if (player == null || !mounted) return;
    // A viewer only counts once something is actually playing.
    if (player.value.playing && !_viewerSessionOpen) {
      _startViewerSession();
    }
    setState(() {});
  }

  void _startViewerSession() {
    _viewerSessionOpen = true;
    final repo = ref.read(liveRepositoryProvider);
    repo.heartbeat(widget.eventId, _viewerKey).catchError((_) => 0);
    _heartbeat = Timer.periodic(const Duration(seconds: 45), (_) {
      repo.heartbeat(widget.eventId, _viewerKey).catchError((_) => 0);
    });
  }

  void _endViewerSession() {
    if (!_viewerSessionOpen) return;
    _viewerSessionOpen = false;
    ref
        .read(liveRepositoryProvider)
        .endViewerSession(widget.eventId, _viewerKey)
        .catchError((_) {});
  }

  void _flashControls() {
    setState(() => _controlsVisible = true);
    _hideControls?.cancel();
    _hideControls = Timer(const Duration(seconds: 4), () {
      if (mounted && (_player?.value.playing ?? false)) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  // --- actions ---------------------------------------------------------

  Future<void> _toggleSave(LiveEventDetail event) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (!ref.read(isLoggedInProvider)) {
      messenger.showSnackBar(SnackBar(
        content: Text(t.signInToSave),
        action: SnackBarAction(
            label: t.signIn, onPressed: () => context.push('/login')),
      ));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(liveRepositoryProvider)
          .setSaved(widget.eventId, saved: !event.saved);
      ref.invalidate(liveEventProvider(widget.eventId));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.genericError)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _react(String kind) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (!ref.read(isLoggedInProvider)) {
      messenger.showSnackBar(SnackBar(content: Text(t.signInToParticipate)));
      return;
    }
    try {
      await ref.read(liveRepositoryProvider).react(widget.eventId, kind);
    } catch (_) {
      // Rate-limited or offline; nothing worth interrupting playback for.
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final async = ref.watch(liveEventProvider(widget.eventId));
    final event = async.asData?.value;

    if (event == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F8F5),
        appBar: AppBar(title: Text(t.liveEvent)),
        body: async.hasError
            ? _ErrorView(
                notFound: async.error is LiveEventNotFound,
                onRetry: () =>
                    ref.invalidate(liveEventProvider(widget.eventId)),
              )
            : const Center(child: CircularProgressIndicator()),
      );
    }

    // Keep timers and the engine in step with the latest payload.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncTimers(event);
      _ensurePlayer(event);
    });

    final title = switch (event.status) {
      LiveStatus.live => t.liveNow,
      LiveStatus.replayAvailable => t.replayTitle,
      _ => t.liveEvent,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F5),
        surfaceTintColor: Colors.transparent,
        foregroundColor: _ink,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (event.sharingAllowed)
            Semantics(
              button: true,
              label: t.shareLabel,
              child: IconButton(
                onPressed: () => SharePlus.instance.share(
                    // Only ever the canonical page, never the stream URL.
                    ShareParams(text: event.canonicalUrl)),
                icon: const Icon(Icons.share_rounded),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) async {
              if (value == 'copy') {
                final messenger = ScaffoldMessenger.of(context);
                await Clipboard.setData(
                    ClipboardData(text: event.canonicalUrl));
                messenger
                    .showSnackBar(SnackBar(content: Text(t.linkCopied)));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'copy', child: Text(t.copyLink)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _Stage(
            event: event,
            player: _player,
            controlsVisible: _controlsVisible,
            onTapSurface: _flashControls,
            onTogglePlay: () {
              final player = _player;
              if (player == null) return;
              player.value.playing ? player.pause() : player.play();
              _flashControls();
            },
            onToggleMute: () {
              final player = _player;
              if (player == null) return;
              player.setMuted(!player.value.muted);
              _flashControls();
            },
            onGoLive: () => _player?.jumpToLive(),
            onRetry: () => _player?.retry(),
            onRefreshStatus: () =>
                ref.invalidate(liveEventProvider(widget.eventId)),
          ),
          _EventInfo(
            event: event,
            saving: _saving,
            onSave: () => _toggleSave(event),
            onReact: _react,
          ),
          const Divider(height: 1, color: _divider),
          TabBar(
            controller: _tabs,
            labelColor: JcfColors.skyPrimary,
            unselectedLabelColor: _sub,
            indicatorColor: JcfColors.skyPrimary,
            labelStyle: const TextStyle(
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            tabs: [
              Tab(text: t.chatTab),
              Tab(text: t.aboutTab),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                LiveChatPanel(eventId: widget.eventId, config: event.chat),
                _AboutTab(event: event),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The video area: poster, waiting room, player or an explanatory state.
class _Stage extends StatelessWidget {
  const _Stage({
    required this.event,
    required this.player,
    required this.controlsVisible,
    required this.onTapSurface,
    required this.onTogglePlay,
    required this.onToggleMute,
    required this.onGoLive,
    required this.onRetry,
    required this.onRefreshStatus,
  });

  final LiveEventDetail event;
  final LivePlaybackController? player;
  final bool controlsVisible;
  final VoidCallback onTapSurface;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleMute;
  final VoidCallback onGoLive;
  final VoidCallback onRetry;
  final VoidCallback onRefreshStatus;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    // Access is decided before anything plays.
    if (!event.access.allowed) {
      return _StageFrame(
        posterUrl: event.posterUrl,
        asset: '$_assets/live_now_player_stream_poster.webp',
        child: _AccessGate(access: event.access),
      );
    }

    if (event.status.isBeforeStart) {
      return _StageFrame(
        posterUrl: '',
        asset: '$_assets/live_now_player_waiting_room.webp',
        child: _WaitingRoom(event: event, onRefresh: onRefreshStatus),
      );
    }

    if (event.status == LiveStatus.cancelled ||
        event.status == LiveStatus.rescheduled) {
      return _StageFrame(
        posterUrl: event.posterUrl,
        asset: '$_assets/live_now_player_stream_poster.webp',
        child: _Notice(
          icon: Icons.event_busy_rounded,
          text: event.cancellationNote.isNotEmpty
              ? event.cancellationNote
              : (event.status == LiveStatus.cancelled
                  ? t.eventCancelled
                  : t.eventRescheduled),
        ),
      );
    }

    if (event.status == LiveStatus.replayProcessing) {
      return _StageFrame(
        posterUrl: event.replay?.thumbnailUrl ?? '',
        asset: '$_assets/live_now_player_replay_thumbnail.webp',
        child: _Notice(
            icon: Icons.hourglass_top_rounded, text: t.replayProcessing),
      );
    }

    if (event.status == LiveStatus.ended ||
        event.status == LiveStatus.unavailable) {
      return _StageFrame(
        posterUrl: event.posterUrl,
        asset: '$_assets/live_now_player_stream_poster.webp',
        child: _Notice(
          icon: Icons.videocam_off_rounded,
          text: event.status == LiveStatus.ended
              ? t.statusEnded
              : t.streamUnavailable,
        ),
      );
    }

    // Playing (live or replay).
    final state = player?.value;
    final isLive = event.status == LiveStatus.live;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: GestureDetector(
        onTap: onTapSurface,
        child: ColoredBox(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (state?.initialized ?? false)
                player!.buildSurface()
              else
                MemberImage(
                  url: event.posterUrl,
                  asset: event.isReplay
                      ? '$_assets/live_now_player_replay_thumbnail.webp'
                      : '$_assets/live_now_player_stream_poster.webp',
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).width * 9 / 16,
                ),

              if (state?.hasError ?? false)
                Center(
                  child: FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(t.retryLabel),
                  ),
                )
              else if (state?.buffering ?? false)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),

              // Status is always visible; the rest fades out during play.
              PositionedDirectional(
                top: 10,
                start: 10,
                child: Row(
                  children: [
                    if (isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _liveRed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sensors_rounded,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              t.statusLive.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 10,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (event.viewerCountVisible) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          t.viewerCount(event.viewerCount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (controlsVisible)
                _PlayerControls(
                  playing: state?.playing ?? false,
                  muted: state?.muted ?? false,
                  isLive: isLive,
                  // A live stream shows no scrubber unless DVR is on.
                  showTimeline:
                      event.isReplay || (event.stream?.dvrEnabled ?? false),
                  position: state?.position ?? Duration.zero,
                  duration: state?.duration ?? Duration.zero,
                  onTogglePlay: onTogglePlay,
                  onToggleMute: onToggleMute,
                  onGoLive: onGoLive,
                  onSeek: (value) =>
                      player?.seekTo(Duration(seconds: value.round())),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageFrame extends StatelessWidget {
  const _StageFrame(
      {required this.posterUrl, required this.asset, required this.child});

  final String posterUrl;
  final String asset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MemberImage(
            url: posterUrl,
            asset: asset,
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).width * 9 / 16,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(color: Color(0x8C000000)),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class _WaitingRoom extends StatefulWidget {
  const _WaitingRoom({required this.event, required this.onRefresh});

  final LiveEventDetail event;
  final VoidCallback onRefresh;

  @override
  State<_WaitingRoom> createState() => _WaitingRoomState();
}

class _WaitingRoomState extends State<_WaitingRoom> {
  Timer? _tick;
  Duration _untilStart = Duration.zero;

  @override
  void initState() {
    super.initState();
    _recompute();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _recompute());
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _recompute() {
    if (!mounted) return;
    final remaining = widget.event.startsAt.difference(DateTime.now());
    // Never negative: at zero the server decides, not the device clock.
    final next = remaining.isNegative ? Duration.zero : remaining;
    if (next.inSeconds != _untilStart.inSeconds) {
      setState(() => _untilStart = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final untilStart = _untilStart;
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    String two(int v) => v.toString().padLeft(2, '0');
    final hours = untilStart.inHours;
    final label = hours > 0
        ? '$hours:${two(untilStart.inMinutes % 60)}:${two(untilStart.inSeconds % 60)}'
        : '${two(untilStart.inMinutes)}:${two(untilStart.inSeconds % 60)}';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          event.status == LiveStatus.startingSoon
              ? t.statusStartingSoon.toUpperCase()
              : t.statusScheduled.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFE9A33A),
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          DateFormat('EEE, d MMM · HH:mm', locale).format(event.startsAt),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        // Never negative: at zero the app asks the server, it does not
        // assume the stream started.
        Text(
          untilStart == Duration.zero ? t.reconnecting : t.startsIn(label),
          style: const TextStyle(
            color: Color(0xFFD7E2F8),
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          t.streamWillBeginHere,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFB9C9F5),
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _AccessGate extends StatelessWidget {
  const _AccessGate({required this.access});

  final LiveAccess access;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final message = switch (access.requiredTier) {
      'students' => t.studentsOnlyEvent,
      'members' => t.membersOnlyEvent,
      _ => t.signInToWatch,
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_rounded, color: Colors.white, size: 30),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (access.signInRequired) ...[
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.push('/login'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: JcfColors.skyPrimary,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(t.signIn),
          ),
        ],
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 10),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PlayerControls extends StatelessWidget {
  const _PlayerControls({
    required this.playing,
    required this.muted,
    required this.isLive,
    required this.showTimeline,
    required this.position,
    required this.duration,
    required this.onTogglePlay,
    required this.onToggleMute,
    required this.onGoLive,
    required this.onSeek,
  });

  final bool playing;
  final bool muted;
  final bool isLive;
  final bool showTimeline;
  final Duration position;
  final Duration duration;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleMute;
  final VoidCallback onGoLive;
  final ValueChanged<double> onSeek;

  String _clock(Duration d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return d.inHours > 0
        ? '${d.inHours}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}'
        : '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final behindLive = isLive &&
        showTimeline &&
        duration > Duration.zero &&
        (duration - position) > const Duration(seconds: 10);

    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color(0x8C000000)),
          ),
        ),
        Center(
          child: Semantics(
            button: true,
            label: playing ? t.pauseLabel : t.playLabel,
            child: IconButton(
              iconSize: 56,
              onPressed: onTogglePlay,
              icon: Icon(
                playing
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ),
        PositionedDirectional(
          bottom: 4,
          start: 4,
          end: 4,
          child: Row(
            children: [
              Semantics(
                button: true,
                label: t.captionsLabel,
                child: IconButton(
                  onPressed: onToggleMute,
                  icon: Icon(
                    muted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              if (showTimeline) ...[
                Text(_clock(position),
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
                Expanded(
                  child: Slider(
                    value: position.inSeconds
                        .toDouble()
                        .clamp(0, max(1, duration.inSeconds).toDouble()),
                    max: max(1, duration.inSeconds).toDouble(),
                    onChanged: onSeek,
                  ),
                ),
                Text(_clock(duration),
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
              ] else
                const Spacer(),
              if (behindLive)
                TextButton(
                  onPressed: onGoLive,
                  child: Text(
                    t.goLive,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventInfo extends StatefulWidget {
  const _EventInfo({
    required this.event,
    required this.saving,
    required this.onSave,
    required this.onReact,
  });

  final LiveEventDetail event;
  final bool saving;
  final VoidCallback onSave;
  final void Function(String kind) onReact;

  @override
  State<_EventInfo> createState() => _EventInfoState();
}

class _EventInfoState extends State<_EventInfo> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final event = widget.event;
    final facilitator = event.facilitator;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(
              color: _ink,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 18,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (event.shortDescription.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              event.shortDescription,
              maxLines: _expanded ? null : 2,
              overflow: _expanded ? null : TextOverflow.ellipsis,
              style: const TextStyle(
                color: _sub,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _expanded ? t.readLess : t.readMore,
                  style: const TextStyle(
                    color: JcfColors.skyPrimary,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
          if (facilitator != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                // A real name without an approved portrait gets initials,
                // never a stock face.
                if (facilitator.avatarUrl.isNotEmpty)
                  ClipOval(
                    child: MemberImage(
                      url: facilitator.avatarUrl,
                      asset:
                          '$_assets/live_now_player_facilitator_fallback.webp',
                      width: 40,
                      height: 40,
                    ),
                  )
                else
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFEAF2FF),
                    child: Text(
                      facilitator.initials,
                      style: const TextStyle(
                        color: JcfColors.skyPrimary,
                        fontFamily: JcfTypography.bodyFamily,
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
                              facilitator.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _ink,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (facilitator.verified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded,
                                size: 14, color: JcfColors.skyPrimary),
                          ],
                        ],
                      ),
                      if (facilitator.role.isNotEmpty)
                        Text(
                          facilitator.role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _sub,
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _Action(
                icon: Icons.favorite_border_rounded,
                label: t.reactLabel,
                onTap: () => widget.onReact('appreciate'),
              ),
              _Action(
                icon: event.saved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                label: event.saved ? t.savedLabel2 : t.saveForLater,
                selected: event.saved,
                onTap: widget.saving ? null : widget.onSave,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(
      {required this.icon, required this.label, required this.onTap,
      this.selected = false});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor:
              selected ? JcfColors.skyPrimary : _ink,
          minimumSize: const Size(0, 44),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            fontFamily: JcfTypography.bodyFamily,
          ),
        ),
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.event});

  final LiveEventDetail event;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final schedule =
        '${DateFormat('EEE, d MMM yyyy · HH:mm', locale).format(event.startsAt)}'
        ' – ${DateFormat.jm(locale).format(event.endsAt)}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (event.fullDescription.isNotEmpty) ...[
          SelectableText(
            event.fullDescription,
            style: const TextStyle(
              color: _ink,
              fontFamily: JcfTypography.bodyFamily,
              fontSize: 15,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
        ],
        _Fact(label: t.eventSchedule, value: schedule),
        if (event.language.isNotEmpty)
          _Fact(label: t.eventLanguage, value: event.language),
        if (event.facilitator case final facilitator?)
          _Fact(label: t.eventFacilitator, value: facilitator.displayName),
        _Fact(
          label: t.onlineLabel,
          value: event.venue.isEmpty ? t.onlineLabel : event.venue,
        ),
        if (event.replay case final replay?)
          _Fact(
            label: t.replayTitle,
            value: replay.ready ? t.watchReplay : t.replayProcessing,
          ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: _sub,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _ink,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.notFound, required this.onRetry});

  final bool notFound;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFFEAF2FF),
            child: Icon(Icons.videocam_off_rounded,
                size: 32, color: JcfColors.skyPrimary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          notFound ? t.streamUnavailable : t.genericError,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _sub,
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: notFound
              ? FilledButton(
                  onPressed: () => context.go('/home'),
                  child: Text(t.backToHome))
              : FilledButton(onPressed: onRetry, child: Text(t.retryLabel)),
        ),
      ],
    );
  }
}
