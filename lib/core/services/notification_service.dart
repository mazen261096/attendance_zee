import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'supabase_service.dart';
import '../notification_service/notification_config.dart';

/// Production-ready, reusable notification service for FCM integration
///
/// Features:
/// - FCM token lifecycle management (request, refresh, save)
/// - Foreground/background notification handling
/// - Type-based notification routing
/// - Supabase integration for token storage
/// - Platform-agnostic design (works on any Flutter project)
///
/// Usage:
/// ```dart
/// final notificationService = NotificationService();
/// await notificationService.initialize();
///
/// // Save token after user login
/// await notificationService.saveFCMToken(userId);
///
/// // Listen to foreground notifications
/// notificationService.onMessageStream.listen((message) {
///   print('Foreground notification: ${message.notification?.title}');
/// });
/// ```
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  // Lazily accessed - do not assign immediately
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  // Local notifications plugin
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Android Notification Channel — driven by AppConfig
  static final AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        AppConfig.notificationChannelId,
        AppConfig.notificationChannelName,
        description: AppConfig.notificationChannelDescription,
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound(AppConfig.notificationSoundName),
      );

  // Track initialization state
  bool _isInitialized = false;
  Future<void>? _initializeFuture;
  RemoteMessage? _pendingInitialMessage;

  final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();

  /// Stream of foreground messages
  Stream<RemoteMessage> get onMessageStream => _messageStreamController.stream;

  /// Initialize FCM and request permissions
  /// Call this once during app startup
  Future<void> initialize() async {
    // Prevent multiple simultaneous initializations
    if (_isInitialized) {
      if (kDebugMode) {
        print('NotificationService already initialized');
      }
      return;
    }

    // If initialization is in progress, wait for it
    if (_initializeFuture != null) {
      if (kDebugMode) {
        print('NotificationService initialization in progress, waiting...');
      }
      return _initializeFuture;
    }

    // Start initialization
    _initializeFuture = _performInitialization();
    await _initializeFuture;
    _initializeFuture = null;
  }

  Future<void> _performInitialization() async {
    try {
      // 1. Initialize Local Notifications
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final data =
                  jsonDecode(response.payload!) as Map<String, dynamic>;
              if (kDebugMode) {
                print('Local notification tapped with data: $data');
              }
              _handleNotificationRoute(data);
            } catch (e) {
              if (kDebugMode) {
                print('Error parsing notification payload: $e');
              }
            }
          }
        },
      );

      // Create Android Channel
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_androidChannel);
      }

      // 2. Check if we can access messaging (implies Firebase init worked)
      final messaging = _messaging;

      // Request notification permissions (iOS)
      // Also updates iOS foreground options
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Enable foreground notification presentation options for iOS
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (kDebugMode) {
        print(
          'Notification permission status: ${settings.authorizationStatus}',
        );
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print(
            'Foreground notification received: ${message.notification?.title}',
          );
        }

        // Show local notification for foreground messages
        _showLocalNotification(message);

        _messageStreamController.add(message);
      });

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Notification tapped (background): ${message.data}');
        }
        _handleNotificationRoute(message.data);
      });

      // Store initial message but DON'T navigate yet - router may not be ready
      _pendingInitialMessage = await messaging.getInitialMessage();
      if (_pendingInitialMessage != null) {
        if (kDebugMode) {
          print('Initial message stored, will handle when router is ready');
        }
      }

      // Listen to token refresh
      messaging.onTokenRefresh.listen((newToken) {
        if (kDebugMode) {
          print('FCM token refreshed: $newToken');
        }
        // Save the new token to Supabase
        final currentUser = SupabaseService().currentUser;
        if (currentUser != null) {
          saveFCMToken(currentUser.id);
        }
      });

      _isInitialized = true;
      if (kDebugMode) {
        print('NotificationService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing NotificationService: $e');
        print(
          'This is expected if Firebase is not configured or on unsupported platform',
        );
      }
    }
  }

  /// Handle pending initial message (call this after router is ready)
  void handlePendingInitialMessage() {
    if (_pendingInitialMessage != null) {
      final data = _pendingInitialMessage!.data;
      _pendingInitialMessage = null;
      if (kDebugMode) {
        print('Handling pending initial message: $data');
      }
      // Delay to ensure router is fully ready and user is authenticated
      Future.delayed(const Duration(seconds: 2), () {
        _handleNotificationRoute(data);
      });
    }
  }

  /// Show a local notification
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: android?.smallIcon,
            priority: Priority.high,
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound(AppConfig.notificationSoundName),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: '${AppConfig.notificationSoundName}.wav',
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Get FCM token and save it to Supabase
  /// Call this after user login
  Future<void> saveFCMToken(String userId) async {
    // Auto-initialize if not already initialized
    if (!_isInitialized) {
      if (kDebugMode) {
        print('NotificationService not initialized, initializing now...');
      }
      await initialize();
    }

    try {
      // Robustly try to get the token
      final token = await _messaging.getToken();
      if (token == null) {
        if (kDebugMode) {
          print('Failed to get FCM token');
        }
        return;
      }

      if (kDebugMode) {
        print('FCM Token: $token');
      }

      // Save token to Supabase — table & column from AppConfig
      await SupabaseService.client
          .from(AppConfig.fcmTokenTable)
          .update({AppConfig.fcmTokenColumn: token})
          .eq('id', userId);

      if (kDebugMode) {
        print('FCM token saved to Supabase for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving FCM token: $e');
        // If it's the "No Firebase App" error, we can explicitly mention it
        if (e.toString().contains('No Firebase App')) {
          print('Firebase not initialized. FCM token saving skipped.');
        }
      }
    }
  }

  /// Clear FCM token from Supabase
  /// Call this on user logout
  Future<void> clearFCMToken(String userId) async {
    try {
      await SupabaseService.client
          .from(AppConfig.fcmTokenTable)
          .update({AppConfig.fcmTokenColumn: null})
          .eq('id', userId);

      if (kDebugMode) {
        print('FCM token cleared for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing FCM token: $e');
      }
    }
  }

  /// Handle notification routing based on type
  /// This is called when a notification is tapped
  void _handleNotificationRoute(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('NotificationService: Handling notification tap');
    }

    // استخدم الـ navigation من الـ config
    NotificationNavigation.handleFCMNotification(data);
  }

  /// Manually handle notification route (for foreground notifications)
  /// Call this from your UI when user taps a foreground notification
  void handleNotificationRoute(Map<String, dynamic> data) {
    _handleNotificationRoute(data);
  }

  /// Dispose resources
  void dispose() {
    _messageStreamController.close();
  }
}

/// Background message handler
/// This must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background notification received: ${message.notification?.title}');
  }
  // Handle background notification here if needed
  // Note: You have limited capabilities in background mode
}
