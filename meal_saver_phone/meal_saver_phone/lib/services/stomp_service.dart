import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class StompService {
  StompClient? _stompClient;

  Future<void> connect() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final url = 'ws://10.0.2.2:8082/ws?token=$token';

    _stompClient = StompClient(
      config: StompConfig(
        url: url,
        onConnect: _onConnectCallback,
        onWebSocketError: (dynamic error) => print('WebSocket Error: $error'),
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
          print('Notification: ${frame.body}');
          NotificationService.showNotification(
            title: 'Food is expired!',
            body: frame.body!,
          );
        }
      },
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
  }
}
