import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

/// What the player exposes to the UI.
class LivePlaybackState {
  const LivePlaybackState({
    this.initialized = false,
    this.playing = false,
    this.buffering = false,
    this.muted = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.error,
  });

  final bool initialized;
  final bool playing;
  final bool buffering;
  final bool muted;
  final Duration position;
  final Duration duration;
  final Object? error;

  bool get hasError => error != null;

  LivePlaybackState copyWith({
    bool? initialized,
    bool? playing,
    bool? buffering,
    bool? muted,
    Duration? position,
    Duration? duration,
    Object? error,
    bool clearError = false,
  }) =>
      LivePlaybackState(
        initialized: initialized ?? this.initialized,
        playing: playing ?? this.playing,
        buffering: buffering ?? this.buffering,
        muted: muted ?? this.muted,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        error: clearError ? null : (error ?? this.error),
      );
}

/// The application's own playback contract.
///
/// Widgets talk to this, never to the video package, so swapping the
/// engine later (for PiP, DRM or low-latency HLS) does not reach the UI.
abstract class LivePlaybackController extends ValueNotifier<LivePlaybackState> {
  LivePlaybackController() : super(const LivePlaybackState());

  Future<void> initialize(String url);
  Future<void> play();
  Future<void> pause();
  Future<void> setMuted(bool muted);
  Future<void> seekTo(Duration position);

  /// Jump back to the live edge (DVR only).
  Future<void> jumpToLive();
  Future<void> retry();

  /// The rendering surface for the current engine.
  Widget buildSurface();
}

/// `video_player` implementation. HLS on iOS and Android via the platform
/// players.
class VideoPlayerPlaybackController extends LivePlaybackController {
  VideoPlayerController? _controller;
  String? _url;
  bool _disposed = false;

  @override
  Future<void> initialize(String url) async {
    _url = url;
    await _controller?.dispose();
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;
    controller.addListener(_onUpdate);
    try {
      await controller.initialize();
      if (_disposed) return;
      value = value.copyWith(
        initialized: true,
        duration: controller.value.duration,
        clearError: true,
      );
    } catch (error) {
      if (_disposed) return;
      value = value.copyWith(initialized: false, error: error);
    }
  }

  void _onUpdate() {
    final controller = _controller;
    if (controller == null || _disposed) return;
    final v = controller.value;
    value = value.copyWith(
      playing: v.isPlaying,
      buffering: v.isBuffering,
      position: v.position,
      duration: v.duration,
      muted: v.volume == 0,
      error: v.hasError ? v.errorDescription : null,
      clearError: !v.hasError,
    );
  }

  @override
  Future<void> play() async => _controller?.play();

  @override
  Future<void> pause() async => _controller?.pause();

  @override
  Future<void> setMuted(bool muted) async {
    await _controller?.setVolume(muted ? 0 : 1);
    value = value.copyWith(muted: muted);
  }

  @override
  Future<void> seekTo(Duration position) async =>
      _controller?.seekTo(position);

  @override
  Future<void> jumpToLive() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.seekTo(controller.value.duration);
    await controller.play();
  }

  @override
  Future<void> retry() async {
    final url = _url;
    if (url == null) return;
    value = const LivePlaybackState();
    await initialize(url);
    await play();
  }

  @override
  Widget buildSurface() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.expand();
    }
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _controller?.removeListener(_onUpdate);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }
}

/// A no-op engine for tests and for states with nothing to play.
class InertPlaybackController extends LivePlaybackController {
  @override
  Future<void> initialize(String url) async {
    value = value.copyWith(initialized: true);
  }

  @override
  Future<void> play() async => value = value.copyWith(playing: true);

  @override
  Future<void> pause() async => value = value.copyWith(playing: false);

  @override
  Future<void> setMuted(bool muted) async =>
      value = value.copyWith(muted: muted);

  @override
  Future<void> seekTo(Duration position) async =>
      value = value.copyWith(position: position);

  @override
  Future<void> jumpToLive() async =>
      value = value.copyWith(position: value.duration, playing: true);

  @override
  Future<void> retry() async => value = const LivePlaybackState(
        initialized: true,
      );

  @override
  Widget buildSurface() => const SizedBox.expand();
}
