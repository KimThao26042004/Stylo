import 'package:flutter/material.dart';
import '../auth_screen/auth_common.dart';

class CustomerServiceScreen extends StatefulWidget {
  const CustomerServiceScreen({super.key});

  @override
  State<CustomerServiceScreen> createState() => _CustomerServiceScreenState();
}

class _CustomerServiceScreenState extends State<CustomerServiceScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  final List<_Msg> _messages = [];
  final List<String> _suggestions = const [
    'What are the measurements of size M pants/ shirts?',
    'Do you have large quantities of inventory?',
    'What color is it now?',
    '1m70 what size to wear',
  ];

  bool get _hasUserMsg => _messages.any((m) => m.isMe);

  @override
  void initState() {
    super.initState();
    // tin nhắn mặc định
    _messages.addAll([
      _Msg(text: 'Hello, good morning.', isMe: false, time: DateTime.now()),
      _Msg(
        text: 'I am a Customer Service, is there anything I can help you with?',
        isMe: false,
        time: DateTime.now(),
      ),
    ]);
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: text.trim(), isMe: true, time: DateTime.now()));
      _ctrl.clear();
    });
    _scrollToBottom();

    // trả lời tự động mẫu
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _messages.addAll([
          _Msg(text: 'Of course...', isMe: false, time: DateTime.now()),
          _Msg(
            text:
            'Please wait for me a minute',
            isMe: false,
            time: DateTime.now(),
          ),
        ]);
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Customer Service',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.call_outlined)),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              children: [
                // nhãn Today
                Center(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Today',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.lightText)),
                  ),
                ),
                const SizedBox(height: 8),
                ..._messages.map(_Bubble.new),

                if (!_hasUserMsg) ...[
                  const SizedBox(height: 10),
                  _SuggestionPanel(
                    suggestions: _suggestions,
                    onTap: (q) => _send(q),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write your message...',
                        ),
                        onSubmitted: _send,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _send(_ctrl.text),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------- Models & UI widgets ---------- */

class _Msg {
  final String text;
  final DateTime time;
  final bool isMe;
  _Msg({required this.text, required this.isMe, required this.time});
}

class _Bubble extends StatelessWidget {
  final _Msg m;
  const _Bubble(this.m);

  @override
  Widget build(BuildContext context) {
    final align =
    m.isMe ? Alignment.centerRight : Alignment.centerLeft;
    final color = m.isMe ? Colors.black : Colors.grey.shade200;
    final textColor = m.isMe ? Colors.white : Colors.black87;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .78,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(m.isMe ? 14 : 4),
            bottomRight: Radius.circular(m.isMe ? 4 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          m.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(m.text, style: TextStyle(color: textColor)),
            const SizedBox(height: 4),
            Text(
              _formatTime(m.time),
              style: const TextStyle(fontSize: 11, color: AppTheme.lightText),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final am = t.hour >= 12 ? 'pm' : 'am';
    return '$h:$m $am';
  }
}

class _SuggestionPanel extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;
  const _SuggestionPanel({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        children: suggestions
            .map((s) => InkWell(
          onTap: () => onTap(s),
          child: Container(
            alignment: Alignment.centerLeft,
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: suggestions.last == s
                        ? Colors.transparent
                        : Colors.grey.shade300),
              ),
            ),
            child: Text(s),
          ),
        ))
            .toList(),
      ),
    );
  }
}
