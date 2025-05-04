import 'package:flutter/material.dart';
import 'package:meal_saver_phone/models/notification_model.dart';
import 'package:meal_saver_phone/services/api_service.dart';
import 'package:intl/intl.dart';

class NotificationsDrawer extends StatefulWidget {
  final VoidCallback? onClose;

  const NotificationsDrawer({this.onClose, super.key});

  @override
  State<NotificationsDrawer> createState() => _NotificationsDrawerState();
}

class _NotificationsDrawerState extends State<NotificationsDrawer> {
  List<AppNotification> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final data = await ApiService().getNotifications();
    setState(() {
      notifications = data;
    });
  }

  Future<void> _markAsRead(int id) async {
    await ApiService().markNotificationAsRead(id);
    await _loadNotifications();
    widget.onClose?.call();
  }

  Future<void> _deleteNotification(int id) async {
    await ApiService().deleteNotification(id);
    await _loadNotifications();
    widget.onClose?.call();
  }

  Future<void> _clearAll() async {
    await ApiService().clearAllNotifications();
    await _loadNotifications();
    widget.onClose?.call();
  }

  void _handleClose() {
    Navigator.of(context).pop();
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 30, 30, 30),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(0),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  15,
                  MediaQuery.of(context).padding.top + 8,
                  8,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.delete_sweep,
                            color: Colors.white,
                          ),
                          tooltip: 'Clear All',
                          onPressed: _clearAll,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          tooltip: 'Close',
                          onPressed: _handleClose,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, thickness: 0.5),
              Expanded(
                child:
                    notifications.isEmpty
                        ? const Center(
                          child: Text(
                            "No notifications",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                        : ListView.separated(
                          itemCount: notifications.length,
                          separatorBuilder:
                              (_, __) => const Divider(
                                color: Colors.white12,
                                height: 1,
                              ),
                          itemBuilder: (context, index) {
                            final n = notifications[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              leading: Icon(
                                n.read
                                    ? Icons.notifications_none
                                    : Icons.notifications_active,
                                color: Colors.deepPurpleAccent,
                              ),
                              title: Text(
                                n.message,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                DateFormat(
                                  'y MMM d – HH:mm',
                                ).format(n.createdAt.toLocal()),
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!n.read)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.greenAccent,
                                      ),
                                      onPressed: () => _markAsRead(n.id),
                                    ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => _deleteNotification(n.id),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
