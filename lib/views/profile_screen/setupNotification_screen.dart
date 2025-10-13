import 'package:flutter/material.dart';
import '../auth_screen/auth_common.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Map<String, bool> _settings = {
    'General Notifications': true,
    'Sound': true,
    'Vibrate': false,
    'Special Offers': true,
    'Promo & Discounts': false,
    'Payments': false,
    'Cashback': true,
    'App Updates': false,
    'New Service Available': true,
    'New Tips Available': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBackBar(title: 'Notifications'),
      body: ListView.separated(
        itemCount: _settings.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final key = _settings.keys.elementAt(i);
          final val = _settings[key]!;
          return SwitchListTile(
            title: Text(key),
            value: val,
            onChanged: (v) => setState(() => _settings[key] = v),
          );
        },
      ),
    );
  }
}
