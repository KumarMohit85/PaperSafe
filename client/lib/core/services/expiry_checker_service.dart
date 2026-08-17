import 'package:papersafe/core/services/notification_service.dart';

class DocumentExpiryItem {
  final int id;
  final String title;
  final DateTime expiryDate;
  final String category;

  DocumentExpiryItem({
    required this.id,
    required this.title,
    required this.expiryDate,
    required this.category,
  });
}

class ExpiryCheckerService {
  final NotificationService _notificationService = NotificationService();

  /// Check a list of documents and schedule notifications for upcoming expiries
  Future<void> checkAndScheduleExpiries(List<DocumentExpiryItem> documents) async {
    await _notificationService.init();

    final now = DateTime.now();

    for (var doc in documents) {
      if (doc.expiryDate.isBefore(now)) {
        // Document already expired - trigger warning notification
        await _notificationService.showNotification(
          id: doc.id,
          title: '⚠️ Expiry Alert: ${doc.title}',
          body: 'Your ${doc.title} expired on ${_formatDate(doc.expiryDate)}. Please renew it.',
          payload: 'doc_id_${doc.id}',
        );
        continue;
      }

      final daysUntilExpiry = doc.expiryDate.difference(now).inDays;

      // 30 Days Reminder
      if (daysUntilExpiry > 30) {
        final scheduleTime = doc.expiryDate.subtract(const Duration(days: 30));
        await _notificationService.scheduleNotification(
          id: doc.id * 100 + 30,
          title: '📅 30 Days Expiry Reminder: ${doc.title}',
          body: 'Your ${doc.title} will expire in 30 days on ${_formatDate(doc.expiryDate)}.',
          scheduledDate: scheduleTime,
          payload: 'doc_id_${doc.id}',
        );
      }

      // 7 Days Reminder
      if (daysUntilExpiry > 7) {
        final scheduleTime = doc.expiryDate.subtract(const Duration(days: 7));
        await _notificationService.scheduleNotification(
          id: doc.id * 100 + 7,
          title: '🚨 7 Days Urgent Reminder: ${doc.title}',
          body: 'Your ${doc.title} expires next week on ${_formatDate(doc.expiryDate)}.',
          scheduledDate: scheduleTime,
          payload: 'doc_id_${doc.id}',
        );
      }

      // 1 Day Reminder
      if (daysUntilExpiry > 1) {
        final scheduleTime = doc.expiryDate.subtract(const Duration(days: 1));
        await _notificationService.scheduleNotification(
          id: doc.id * 100 + 1,
          title: '⏰ Expires Tomorrow: ${doc.title}',
          body: 'Final Reminder: Your ${doc.title} expires tomorrow!',
          scheduledDate: scheduleTime,
          payload: 'doc_id_${doc.id}',
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
