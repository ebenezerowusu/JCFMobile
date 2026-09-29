import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// Destination identifiers the API may send. Mapped to app routes; a raw
/// route string from the server is never navigated to.
enum StudentDestination {
  lesson,
  practice,
  program,
  liveClass,
  milestone,
  mentor,
  announcement,
  unknown;

  static StudentDestination parse(String? id) => switch (id) {
        'lesson' => StudentDestination.lesson,
        'practice' => StudentDestination.practice,
        'program' => StudentDestination.program,
        'live_class' => StudentDestination.liveClass,
        'milestone' => StudentDestination.milestone,
        'mentor' => StudentDestination.mentor,
        'announcement' => StudentDestination.announcement,
        _ => StudentDestination.unknown,
      };
}

class StudentSummary {
  const StudentSummary({
    required this.preferredName,
    required this.firstName,
    required this.studentStatus,
    this.avatarUrl = '',
    this.accessExpiresAt,
  });

  final String preferredName;
  final String firstName;

  /// active | paused | completed | expired | suspended | none
  final String studentStatus;
  final String avatarUrl;
  final DateTime? accessExpiresAt;

  /// preferredName → firstName → null. Contact details are never a name.
  String? get displayName {
    if (preferredName.trim().isNotEmpty) return preferredName.trim();
    if (firstName.trim().isNotEmpty) return firstName.trim();
    return null;
  }

  bool get accessExpired =>
      accessExpiresAt != null && accessExpiresAt!.isBefore(DateTime.now());

  factory StudentSummary.fromJson(Map<String, dynamic> json) => StudentSummary(
        preferredName: json['preferred_name'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        studentStatus: json['student_status'] as String? ?? 'none',
        avatarUrl: json['avatar_url'] as String? ?? '',
        accessExpiresAt: json['access_expires_at'] == null
            ? null
            : DateTime.tryParse(json['access_expires_at'] as String)?.toLocal(),
      );
}

class ProgramEnrolment {
  const ProgramEnrolment({
    required this.enrolmentId,
    required this.programId,
    required this.programTitle,
    required this.cohort,
    required this.intake,
    required this.currentModuleTitle,
    required this.progressPercentage,
    required this.status,
    required this.isPrimary,
    required this.destination,
    this.currentModuleId,
    this.imageUrl = '',
  });

  final int enrolmentId;
  final String programId;
  final String programTitle;
  final String cohort;
  final String intake;
  final String currentModuleTitle;
  final int progressPercentage;
  final String status;
  final bool isPrimary;
  final StudentDestination destination;
  final String? currentModuleId;
  final String imageUrl;

  bool get isActive => status == 'active';
  int get clampedPercent => progressPercentage.clamp(0, 100);

  factory ProgramEnrolment.fromJson(Map<String, dynamic> json) =>
      ProgramEnrolment(
        enrolmentId: json['enrolment_id'] as int? ?? 0,
        programId: json['program_id'] as String? ?? '',
        programTitle: json['program_title'] as String? ?? '',
        cohort: json['cohort'] as String? ?? '',
        intake: json['intake'] as String? ?? '',
        currentModuleTitle: json['current_module_title'] as String? ?? '',
        progressPercentage: json['progress_percentage'] as int? ?? 0,
        status: json['status'] as String? ?? 'active',
        isPrimary: json['is_primary'] as bool? ?? false,
        destination:
            StudentDestination.parse(json['destination_id'] as String?),
        currentModuleId: json['current_module_id'] as String?,
        imageUrl: json['image_url'] as String? ?? '',
      );
}

class CourseProgress {
  const CourseProgress({
    required this.courseTitle,
    required this.moduleTitle,
    required this.lessonTitle,
    required this.lessonType,
    required this.progressPercentage,
    required this.started,
    required this.accessGranted,
    required this.destination,
    this.courseId = '',
    this.lessonId,
    this.remainingSeconds,
    this.imageUrl = '',
  });

  final String courseTitle;
  final String moduleTitle;
  final String lessonTitle;
  final String lessonType; // video | audio | written | live | quiz | ...
  final int progressPercentage;
  final bool started;
  final bool accessGranted;
  final StudentDestination destination;
  final String courseId;
  final String? lessonId;
  final int? remainingSeconds;
  final String imageUrl;

  int get clampedPercent => progressPercentage.clamp(0, 100);
  bool get finished => clampedPercent >= 100;

  factory CourseProgress.fromJson(Map<String, dynamic> json) => CourseProgress(
        courseTitle: json['course_title'] as String? ?? '',
        moduleTitle: json['module_title'] as String? ?? '',
        lessonTitle: json['lesson_title'] as String? ?? '',
        lessonType: json['lesson_type'] as String? ?? 'video',
        progressPercentage: json['progress_percentage'] as int? ?? 0,
        started: json['started'] as bool? ?? false,
        accessGranted: json['access_granted'] as bool? ?? false,
        destination:
            StudentDestination.parse(json['destination_id'] as String?),
        courseId: json['course_id'] as String? ?? '',
        lessonId: json['lesson_id'] as String?,
        remainingSeconds: json['remaining_seconds'] as int?,
        imageUrl: json['image_url'] as String? ?? '',
      );
}

class PracticeAssignment {
  const PracticeAssignment({
    required this.assignmentId,
    required this.practiceId,
    required this.title,
    required this.practiceType,
    required this.status,
    required this.required,
    required this.destination,
    this.durationSeconds,
    this.dueAt,
    this.imageUrl = '',
  });

  final int assignmentId;
  final String practiceId;
  final String title;
  final String practiceType;

  /// not_started | in_progress | completed | due_soon | overdue | excused
  final String status;
  final bool required;
  final StudentDestination destination;
  final int? durationSeconds;
  final DateTime? dueAt;
  final String imageUrl;

  factory PracticeAssignment.fromJson(Map<String, dynamic> json) =>
      PracticeAssignment(
        assignmentId: json['assignment_id'] as int? ?? 0,
        practiceId: json['practice_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        practiceType: json['practice_type'] as String? ?? '',
        status: json['status'] as String? ?? 'not_started',
        required: json['required'] as bool? ?? true,
        destination:
            StudentDestination.parse(json['destination_id'] as String?),
        durationSeconds: json['duration_seconds'] as int?,
        dueAt: json['due_at'] == null
            ? null
            : DateTime.tryParse(json['due_at'] as String)?.toLocal(),
        imageUrl: json['image_url'] as String? ?? '',
      );
}

class LiveClass {
  const LiveClass({
    required this.sessionId,
    required this.title,
    required this.moduleTitle,
    required this.facilitator,
    required this.startsAt,
    required this.serverStatus,
    required this.joinAllowed,
    required this.reminderEnabled,
    required this.destination,
    this.endsAt,
    this.timezone = '',
    this.joinUrl = '',
    this.replayUrl = '',
    this.venue = '',
    this.imageUrl = '',
  });

  final int sessionId;
  final String title;
  final String moduleTitle;
  final String facilitator;
  final DateTime startsAt;
  final DateTime? endsAt;

  /// What the server said when the payload was built. Recomputed locally so
  /// cached content is never presented as live after the session ended.
  final String serverStatus;
  final bool joinAllowed;
  final bool reminderEnabled;
  final StudentDestination destination;
  final String timezone;
  final String joinUrl;
  final String replayUrl;
  final String venue;
  final String imageUrl;

  /// live | starting_soon | upcoming | replay | missed | cancelled
  String status(DateTime now) {
    if (serverStatus == 'cancelled' || serverStatus == 'rescheduled') {
      return serverStatus;
    }
    final end = endsAt;
    if (!now.isBefore(startsAt)) {
      if (end != null && now.isBefore(end)) return 'live';
      if (replayUrl.isNotEmpty) return 'replay';
      return 'missed';
    }
    if (startsAt.difference(now) <= const Duration(minutes: 60)) {
      return 'starting_soon';
    }
    return 'upcoming';
  }

  /// Joining is allowed only inside the server's window *and* while the
  /// session is genuinely running now.
  bool canJoin(DateTime now) =>
      joinAllowed && status(now) == 'live';

  factory LiveClass.fromJson(Map<String, dynamic> json) => LiveClass(
        sessionId: json['session_id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        moduleTitle: json['module_title'] as String? ?? '',
        facilitator: json['facilitator'] as String? ?? '',
        startsAt: DateTime.parse(json['starts_at'] as String).toLocal(),
        endsAt: json['ends_at'] == null
            ? null
            : DateTime.tryParse(json['ends_at'] as String)?.toLocal(),
        serverStatus: json['status'] as String? ?? 'upcoming',
        joinAllowed: json['join_allowed'] as bool? ?? false,
        reminderEnabled: json['reminder_enabled'] as bool? ?? false,
        destination:
            StudentDestination.parse(json['destination_id'] as String?),
        timezone: json['timezone'] as String? ?? '',
        joinUrl: json['join_url'] as String? ?? '',
        replayUrl: json['replay_url'] as String? ?? '',
        venue: json['venue'] as String? ?? '',
        imageUrl: json['image_url'] as String? ?? '',
      );
}

class ProgressSummary {
  const ProgressSummary({
    required this.programPercentage,
    required this.completedLessons,
    required this.totalLessons,
    required this.completedPractices,
    required this.requiredPractices,
    required this.currentStreak,
    this.nextMilestonePercentage,
  });

  final int programPercentage;
  final int completedLessons;
  final int totalLessons;
  final int completedPractices;
  final int requiredPractices;
  final int currentStreak;
  final int? nextMilestonePercentage;

  int get clampedPercent => programPercentage.clamp(0, 100);

  factory ProgressSummary.fromJson(Map<String, dynamic> json) =>
      ProgressSummary(
        programPercentage: json['program_percentage'] as int? ?? 0,
        completedLessons: json['completed_lessons'] as int? ?? 0,
        totalLessons: json['total_lessons'] as int? ?? 0,
        completedPractices: json['completed_practices'] as int? ?? 0,
        requiredPractices: json['required_practices'] as int? ?? 0,
        currentStreak: json['current_streak'] as int? ?? 0,
        nextMilestonePercentage: json['next_milestone_percentage'] as int?,
      );
}

class StudentMilestone {
  const StudentMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.currentProgress,
    required this.requiredProgress,
    required this.status,
    required this.destination,
    this.imageUrl = '',
  });

  final int id;
  final String title;
  final String description;
  final int currentProgress;
  final int requiredProgress;

  /// locked | in_progress | achieved | expired
  final String status;
  final StudentDestination destination;
  final String imageUrl;

  int get clampedPercent => currentProgress.clamp(0, 100);

  factory StudentMilestone.fromJson(Map<String, dynamic> json) =>
      StudentMilestone(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        currentProgress: json['current_progress'] as int? ?? 0,
        requiredProgress: json['required_progress'] as int? ?? 100,
        status: json['status'] as String? ?? 'locked',
        destination:
            StudentDestination.parse(json['destination_id'] as String?),
        imageUrl: json['image_url'] as String? ?? '',
      );
}

class StudentMentor {
  const StudentMentor({
    required this.id,
    required this.displayName,
    required this.role,
    required this.availability,
    required this.messagingEnabled,
    required this.bookingEnabled,
    required this.destination,
    this.nextCheckInAt,
    this.avatarUrl = '',
  });

  final int id;
  final String displayName;
  final String role;
  final String availability;
  final bool messagingEnabled;
  final bool bookingEnabled;
  final StudentDestination destination;
  final DateTime? nextCheckInAt;
  final String avatarUrl;

  factory StudentMentor.fromJson(Map<String, dynamic> json) => StudentMentor(
        id: json['id'] as int? ?? 0,
        displayName: json['display_name'] as String? ?? '',
        role: json['role'] as String? ?? '',
        availability: json['availability'] as String? ?? '',
        messagingEnabled: json['messaging_enabled'] as bool? ?? false,
        bookingEnabled: json['booking_enabled'] as bool? ?? false,
        destination:
            StudentDestination.parse(json['destination_id'] as String?),
        nextCheckInAt: json['next_check_in_at'] == null
            ? null
            : DateTime.tryParse(json['next_check_in_at'] as String)?.toLocal(),
        avatarUrl: json['avatar_url'] as String? ?? '',
      );
}

class StudentUpdate {
  const StudentUpdate({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.priority,
    required this.read,
    required this.destination,
    this.publishedAt,
    this.dueAt,
  });

  final String id;

  /// announcement | assignment | schedule_change | mentor_notice | ...
  final String type;
  final String title;
  final String summary;

  /// normal | important | urgent
  final String priority;
  final bool read;
  final StudentDestination destination;
  final DateTime? publishedAt;
  final DateTime? dueAt;

  factory StudentUpdate.fromJson(Map<String, dynamic> json) => StudentUpdate(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? 'announcement',
        title: json['title'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        priority: json['priority'] as String? ?? 'normal',
        read: json['read'] as bool? ?? true,
        destination:
            StudentDestination.parse(json['destination_id'] as String?),
        publishedAt: json['published_at'] == null
            ? null
            : DateTime.tryParse(json['published_at'] as String)?.toLocal(),
        dueAt: json['due_at'] == null
            ? null
            : DateTime.tryParse(json['due_at'] as String)?.toLocal(),
      );
}

class StudentQuickAction {
  const StudentQuickAction({required this.id, required this.sortOrder});

  final String id; // courses | schedule | assignments | downloads
  final int sortOrder;

  factory StudentQuickAction.fromJson(Map<String, dynamic> json) =>
      StudentQuickAction(
        id: json['id'] as String? ?? '',
        sortOrder: json['sort_order'] as int? ?? 0,
      );
}

class StudentHomePayload {
  const StudentHomePayload({
    required this.summary,
    required this.activeEnrolments,
    required this.assignedPractices,
    required this.progress,
    required this.updates,
    required this.quickActions,
    required this.unreadNotificationCount,
    required this.fetchedAt,
    this.primaryEnrolment,
    this.continueCourse,
    this.nextLiveClass,
    this.nextMilestone,
    this.mentor,
  });

  final StudentSummary summary;
  final List<ProgramEnrolment> activeEnrolments;
  final List<PracticeAssignment> assignedPractices;
  final ProgressSummary progress;
  final List<StudentUpdate> updates;
  final List<StudentQuickAction> quickActions;
  final int unreadNotificationCount;
  final DateTime fetchedAt;
  final ProgramEnrolment? primaryEnrolment;
  final CourseProgress? continueCourse;
  final LiveClass? nextLiveClass;
  final StudentMilestone? nextMilestone;
  final StudentMentor? mentor;

  bool get hasOpenEnrolment => activeEnrolments.isNotEmpty;

  /// A restricted state the screen explains rather than erroring on.
  String? get restriction {
    final enrolment = primaryEnrolment;
    if (enrolment == null) return 'none';
    if (hasOpenEnrolment) return null;
    if (summary.accessExpired) return 'expired';
    return enrolment.status; // paused | completed | suspended | expired
  }

  factory StudentHomePayload.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) => [
          for (final row in (json[key] as List? ?? []))
            parse(row as Map<String, dynamic>)
        ];
    Map<String, dynamic>? obj(String key) =>
        json[key] as Map<String, dynamic>?;
    return StudentHomePayload(
      summary: StudentSummary.fromJson(obj('student_summary') ?? const {}),
      activeEnrolments: list('active_enrolments', ProgramEnrolment.fromJson),
      assignedPractices:
          list('assigned_practices', PracticeAssignment.fromJson),
      progress: ProgressSummary.fromJson(obj('progress_summary') ?? const {}),
      updates: list('updates', StudentUpdate.fromJson),
      quickActions: list('quick_actions', StudentQuickAction.fromJson)
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
      unreadNotificationCount: json['unread_notification_count'] as int? ?? 0,
      fetchedAt:
          DateTime.tryParse(json['fetched_at'] as String? ?? '')?.toLocal() ??
              DateTime.now(),
      primaryEnrolment: obj('primary_enrolment') == null
          ? null
          : ProgramEnrolment.fromJson(obj('primary_enrolment')!),
      continueCourse: obj('continue_course') == null
          ? null
          : CourseProgress.fromJson(obj('continue_course')!),
      nextLiveClass: obj('next_live_class') == null
          ? null
          : LiveClass.fromJson(obj('next_live_class')!),
      nextMilestone: obj('next_milestone') == null
          ? null
          : StudentMilestone.fromJson(obj('next_milestone')!),
      mentor: obj('mentor') == null
          ? null
          : StudentMentor.fromJson(obj('mentor')!),
    );
  }
}

class StudentHomeRepository {
  StudentHomeRepository(this._dio);

  final Dio _dio;

  Future<StudentHomePayload> load() async {
    final res = await _dio.get<Map<String, dynamic>>('home/student/');
    return StudentHomePayload.fromJson(res.data!);
  }
}

final studentHomeRepositoryProvider = Provider<StudentHomeRepository>(
    (ref) => StudentHomeRepository(ref.watch(dioProvider)));

final studentHomeProvider = FutureProvider<StudentHomePayload>(
    (ref) => ref.watch(studentHomeRepositoryProvider).load());
