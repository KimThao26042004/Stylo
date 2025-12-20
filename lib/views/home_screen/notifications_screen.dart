import 'package:flutter/material.dart';
import '../auth_screen/auth_common.dart';

/// Dữ liệu 1 item thông báo
class NotifItem {
  final IconData icon;
  final String title;
  final String subtitle;
  const NotifItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

/// Nhóm thông báo theo ngày/nhãn (Today, Yesterday, …)
class NotifSection {
  final String header;
  final List<NotifItem> children;
  const NotifSection(this.header, this.children);
}

class NotificationsScreen extends StatelessWidget {
  static const routeName = '/notifications';

  /// Nếu để trống (mặc định) -> hiện empty-state
  final List<NotifSection> sections;
  const NotificationsScreen({super.key, this.sections = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBackBar(title: 'Notifications'),
      body: sections.isEmpty ? const _EmptyNotifications() : _NotificationsList(sections: sections),
    );
  }
}

/// ========== Empty-state ==========
class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.notifications_none, size: 64, color: AppTheme.lightText),
            SizedBox(height: 16),
            Text(
              "You haven't gotten any\nnotifications yet!",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "We'll alert you when something\ncool happens.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.lightText),
            ),
          ],
        ),
      ),
    );
  }
}

/// ========== List có dữ liệu ==========
class _NotificationsList extends StatelessWidget {
  final List<NotifSection> sections;
  const _NotificationsList({required this.sections});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemBuilder: (_, i) {
        final section = sections[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.header, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            ...section.children.map((it) => _NotifTile(item: it)),
          ],
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: sections.length,
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotifItem item;
  const _NotifTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(item.icon, color: Colors.black87),
          ),
          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(item.subtitle, style: const TextStyle(color: AppTheme.lightText)),
          onTap: () {},
        ),
        Divider(height: 1, color: Colors.grey.shade300),
      ],
    );
  }
}
