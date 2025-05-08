import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class StompService {
  static final StompService _instance = StompService._internal();
  factory StompService() => _instance;
  StompService._internal();

  StompClient? _stompClient;
  void Function()? onNotificationReceived;

  Future<void> connect() async {
    if (_stompClient != null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final url = 'ws://10.0.2.2:8082/ws?token=$token';

    _stompClient = StompClient(
      config: StompConfig(
        url: url,
        onConnect: _onConnectCallback,
        onWebSocketError: (error) => print('WebSocket Error: $error'),
        onStompError: (frame) => print('STOMP Error: ${frame.body}'),
        onDisconnect: (_) => print('Disconnected from STOMP'),
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _stompClient!.activate();
  }

  void _onConnectCallback(StompFrame frame) {
    print('✅ Connected to STOMP');

    _stompClient?.subscribe(
      destination: '/user/queue/expired',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          NotificationService.showNotification(
            title: 'Food is expired!',
            body: frame.body!,
          );
          onNotificationReceived?.call();
        }
      },
    );

    _stompClient?.subscribe(
      destination: '/user/queue/expiring',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          NotificationService.showNotification(
            title: 'Food is expiring soon!',
            body: frame.body!,
          );
          onNotificationReceived?.call();
        }
      },
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
  }
}
