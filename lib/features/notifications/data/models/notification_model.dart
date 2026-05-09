import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/enums.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String titleEn;
  final String titleAr;
  final String? bodyEn;
  final String? bodyAr;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.titleEn,
    required this.titleAr,
    this.bodyEn,
    this.bodyAr,
    required this.type,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      titleEn: json['title_en'] ?? '',
      titleAr: json['title_ar'] ?? '',
      bodyEn: json['body_en'],
      bodyAr: json['body_ar'],
      type: NotificationType.fromString(json['type'] ?? 'join_approved'),
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Returns the localized title based on the current app locale.
  String localizedTitle(BuildContext context) {
    final lang = context.locale.languageCode;
    return lang == 'ar' ? titleAr : titleEn;
  }

  /// Returns the localized body based on the current app locale.
  String? localizedBody(BuildContext context) {
    final lang = context.locale.languageCode;
    return lang == 'ar' ? bodyAr : bodyEn;
  }

  /// Navigation helpers from the data payload
  String? get courseId => data?['course_id'] as String?;
  String? get lectureId => data?['lecture_id'] as String?;
  String? get gradeItemId => data?['grade_item_id'] as String?;
  String? get fileId => data?['file_id'] as String?;

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? titleEn,
    String? titleAr,
    String? bodyEn,
    String? bodyAr,
    NotificationType? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      bodyEn: bodyEn ?? this.bodyEn,
      bodyAr: bodyAr ?? this.bodyAr,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
