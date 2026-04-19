# نظام الإشعارات - Notification System

## الفكرة ببساطة

كل notification له 3 حاجات:
1. **الداتا** - البيانات اللي بتيجي مع الإشعار
2. **UI** - الشكل (أيقونة + لون)
3. **Navigation** - يروح فين لما تضغط عليه

كل ده في ملف واحد: [`notification_config.dart`](file:///Users/mazen/StudioProjects/attendance_zee/lib/core/notification_service/notification_config.dart)

---

## إزاي تضيف نوع notification جديد؟

### 1. ضيف النوع في الـ Enum

```dart
enum NotificationType {
  questionReceived,
  questionAnswered,
  newType,  // ← النوع الجديد
}
```

### 2. ضيف الداتا في `NotificationData`

```dart
class NotificationData {
  // ... existing code
  
  // New Type Data - ضيف الحقول اللي محتاجها
  String? get newId => data['new_id'] as String?;
  String? get newName => data['new_name'] as String?;
  
  // ... rest of code
}
```

### 3. ضيف الـ String Mapping

```dart
static NotificationType? parseType(String? typeString) {
  switch (typeString) {
    case 'question_received':
      return NotificationType.questionReceived;
    case 'question_answered':
      return NotificationType.questionAnswered;
    case 'new_type':  // ← النوع الجديد
      return NotificationType.newType;
    default:
      return null;
  }
}
```

### 4. ضيف الـ UI (الشكل)

```dart
static NotificationUI forType(NotificationType type, ThemeData theme) {
  switch (type) {
    // ... existing cases
    
    case NotificationType.newType:
      return NotificationUI(
        icon: Icons.your_icon,  // الأيقونة
        color: Colors.blue,     // اللون
        title: 'العنوان',
        body: 'الوصف',
      );
  }
}
```

### 5. ضيف الـ Navigation (يروح فين)

```dart
static void navigate(BuildContext context, NotificationData data) {
  switch (data.type) {
    // ... existing cases
    
    case NotificationType.newType:
      _goToNewType(context, data);
      break;
  }
}

// Function للنافيجيشن
static void _goToNewType(BuildContext context, NotificationData data) {
  final id = data.newId;
  if (id != null) {
    context.push('/your-route/$id');
  }
}
```

---

## الأنواع الموجودة حاليًا

### 1. سؤال جديد (`question_received`)
- **الداتا**: questionId, profileId, askerUserId, questionPreview
- **الأيقونة**: `Icons.question_answer`
- **اللون**: Primary color
- **يروح فين**: صفحة البروفايل

### 2. رد على سؤال (`question_answered`)
- **الداتا**: questionId, profileId, responderUserId, answerPreview
- **الأيقونة**: `Icons.check_circle_outline`
- **اللون**: أخضر
- **يروح فين**: صفحة البروفايل

---

## الاستخدام في الكود

### لما يضغط على notification

```dart
// في NotificationListItem
onTap: () {
  final data = notification.notificationData;
  if (data != null) {
    NotificationNavigation.navigate(context, data);
  }
}
```

### جلب الـ UI

```dart
final notifType = notification.notificationType;
if (notifType != null) {
  final ui = NotificationUI.forType(notifType, theme);
  // استخدم ui.icon, ui.color, ui.title
}
```

### جلب الداتا

```dart
final data = notification.notificationData;
if (data != null) {
  print(data.questionId);
  print(data.profileId);
}
```

---

## الملفات المهمة

- **[`notification_config.dart`](file:///Users/mazen/StudioProjects/attendance_zee/lib/core/notification_service/notification_config.dart)** - كل حاجة في ملف واحد
- **[`notification_model.dart`](file:///Users/mazen/StudioProjects/attendance_zee/lib/features/notifications/data/models/notification_model.dart)** - النموذج من Supabase
- **[`notification_list_item.dart`](file:///Users/mazen/StudioProjects/attendance_zee/lib/features/notifications/view/widgets/notification_list_item.dart)** - الـ UI

---

## خلاصة

- كل حاجة في ملف واحد سهل
- عايز تضيف نوع جديد؟ 5 خطوات بس
- الكود واضح وسهل التعديل
