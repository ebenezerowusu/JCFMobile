/// A foundation announcement.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.audience,
    this.imageUrl = '',
    this.pinned = false,
    this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final String audience;
  final String imageUrl;
  final bool pinned;
  final String? createdAt;

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        audience: json['audience'] as String? ?? 'public',
        imageUrl: json['image_url'] as String? ?? '',
        pinned: json['pinned'] as bool? ?? false,
        createdAt: json['created_at'] as String?,
      );
}

/// An in-app notification.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final bool isRead;
  final String? createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        isRead: json['is_read'] as bool? ?? false,
        createdAt: json['created_at'] as String?,
      );
}

/// A consultation/appointment.
class Appointment {
  const Appointment({
    required this.id,
    required this.mode,
    required this.scheduledDate,
    required this.status,
    this.note = '',
  });

  final int id;
  final String mode; // Remote | Onsite
  final String scheduledDate;
  final String status; // requested | confirmed | completed | cancelled
  final String note;

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] as int,
        mode: json['mode'] as String? ?? '',
        scheduledDate: json['scheduled_date'] as String? ?? '',
        status: json['status'] as String? ?? 'requested',
        note: json['note'] as String? ?? '',
      );
}
