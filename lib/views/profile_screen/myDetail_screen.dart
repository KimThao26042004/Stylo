import 'package:flutter/material.dart';
import '../auth_screen/auth_common.dart';

class MyDetailScreen extends StatefulWidget {
  const MyDetailScreen({super.key});

  @override
  State<MyDetailScreen> createState() => _MyDetailScreenState();
}

class _MyDetailScreenState extends State<MyDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: 'Cody Fisher');
  final _email = TextEditingController(text: 'cody.fisher45@example.com');
  final _dob = TextEditingController(text: '12/07/1990');
  String _gender = 'Male';
  final _phone = TextEditingController(text: '+1 234 453 231 506');

  @override
  void dispose() { _name.dispose(); _email.dispose(); _dob.dispose(); _phone.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBackBar(title: 'My Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(decoration: AppTheme.input('Full Name'), controller: _name),
            const SizedBox(height: 12),
            TextFormField(decoration: AppTheme.input('Email Address'), controller: _email, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            TextFormField(
              decoration: AppTheme.input('Date of Birth').copyWith(
                suffixIcon: IconButton(icon: const Icon(Icons.calendar_today_outlined), onPressed: () {}),
              ),
              controller: _dob,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: AppTheme.input('Gender'),
              value: _gender,
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => _gender = v ?? 'Male'),
            ),
            const SizedBox(height: 12),
            TextFormField(decoration: AppTheme.input('Phone Number'), controller: _phone, keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            ElevatedButton(
              style: AppTheme.primaryButton(context),
              onPressed: () {/* TODO: call API to update profile */},
              child: const Text('Submit'),
            ),
          ]),
        ),
      ),
    );
  }
}
