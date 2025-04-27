// lib/features/auth/presentation/widgets/notification_bell.dart
import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/colors.dart';
import 'package:the_boost/core/constants/dimensions.dart';
import 'package:the_boost/core/di/dependency_injection.dart';
import 'package:the_boost/core/services/notification_service.dart';
import 'package:the_boost/features/auth/domain/entities/notification.dart';
import 'package:provider/provider.dart';

class NotificationBell extends StatefulWidget {
  final VoidCallback? onOpenPreferences;
  
  const NotificationBell({
    Key? key,
    this.onOpenPreferences,
  }) : super(key: key);

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unreadCount = 0;
  bool _isLoading = true;
  final NotificationService _notificationService = getIt<NotificationService>();
  
  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }
  
  Future<void> _loadUnreadCount() async {
    setState(() {
      _isLoading = true;
    });
    
    final count = await _notificationService.getUnreadCount();
    
    setState(() {
      _unreadCount = count;
      _isLoading = false;
    });
  }
  
  void _showNotificationsPanel() async {
    final notifications = await _notificationService.getNotifications();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => NotificationsDialog(
        notifications: notifications,
        onMarkAllRead: () async {
          await _notificationService.markAllAsRead();
          _loadUnreadCount();
          Navigator.pop(context);
        },
        onNotificationTap: (notification) async {
          await _notificationService.markAsRead(notification.id);
          _loadUnreadCount();
          
          // Handle navigation based on notification type
          if (notification.type == NotificationType.MATCH_PREFERENCES && 
              notification.landId != null) {
            // Navigate to property details
            Navigator.pop(context); // Close dialog
            Navigator.pushNamed(
              context,
              '/property-details',
              arguments: notification.landId,
            );
          }
        },
        onOpenPreferences: widget.onOpenPreferences,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: _showNotificationsPanel,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
              size: 26,
            ),
            if (_unreadCount > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NotificationsDialog extends StatelessWidget {
  final List<UserNotification> notifications;
  final VoidCallback? onMarkAllRead;
  final Function(UserNotification)? onNotificationTap;
  final VoidCallback? onOpenPreferences;
  
  const NotificationsDialog({
    Key? key,
    required this.notifications,
    this.onMarkAllRead,
    this.onNotificationTap,
    this.onOpenPreferences,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildNotificationsList(),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusL),
          topRight: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Row(
            children: [
              if (onMarkAllRead != null)
                TextButton.icon(
                  onPressed: onMarkAllRead,
                  icon: const Icon(
                    Icons.done_all,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'Mark All Read',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationsList() {
    if (notifications.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.paddingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            const Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            const Text(
              'We\'ll notify you when we find lands that match your preferences',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return Flexible(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }
  
  Widget _buildNotificationItem(UserNotification notification) {
    Color bgColor = notification.isRead 
        ? Colors.white 
        : AppColors.backgroundGreen.withOpacity(0.3);
    
    IconData iconData;
    Color iconColor;
    
    switch (notification.type) {
      case NotificationType.NEW_LAND:
        iconData = Icons.add_location_alt;
        iconColor = Colors.green;
        break;
      case NotificationType.PRICE_DROP:
        iconData = Icons.trending_down;
        iconColor = Colors.orange;
        break;
      case NotificationType.MATCH_PREFERENCES:
        iconData = Icons.thumb_up;
        iconColor = AppColors.primary;
        break;
      case NotificationType.SYSTEM_ALERT:
        iconData = Icons.info;
        iconColor = Colors.blue;
        break;
      case NotificationType.DOCUMENT_UPDATE:
        iconData = Icons.description;
        iconColor = Colors.purple;
        break;
    }
    
    return InkWell(
      onTap: () => onNotificationTap?.call(notification),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        color: bgColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Preferences'),
            onPressed: () {
              Navigator.pop(context);
              onOpenPreferences?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}