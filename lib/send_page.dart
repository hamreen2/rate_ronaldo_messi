import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';

/// Screen 1: the form students fill in on their phones.
class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final _name = TextEditingController();
  final _comment = TextEditingController();
  Player? _player; // which player is being rated
  int _rating = 0;
  bool _sending = false;
  int _cooldown = 0; // seconds before the next vote is allowed
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _name.dispose();
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    // Layer 1 validation: friendly messages on the screen.
    if (_player == null) {
      _toast('Please choose a player.');
      return;
    }
    if (_rating == 0) {
      _toast('Please choose a rating from 1 to 5 stars.');
      return;
    }
    setState(() => _sending = true);
    try {
      // This single call is the INSERT INTO player_feedback ... of your SQL course.
      await Supabase.instance.client.from('player_feedback').insert({
        'player': _player!.name,
        'name': _name.text.trim().isEmpty ? null : _name.text.trim(),
        'comment': _comment.text.trim().isEmpty ? null : _comment.text.trim(),
        'rating': _rating,
      });
      _toast('Thank you! Look at the screen.');
      _name.clear();
      _comment.clear();
      setState(() {
        _rating = 0;
        _player = null;
      });
      _startCooldown();
    } on PostgrestException catch (e) {
      // Layer 2 validation: the database said no (CHECK, RLS policy...).
      _toast('Could not send: ${e.message}');
    } catch (e) {
      _toast('Could not send: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _startCooldown() {
    setState(() => _cooldown = 5);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final canSend = !_sending && _cooldown <= 0;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ronaldo or Messi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/wall'),
            child: const Text('See results'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('1. Who do you want to rate?',
                    style: textTheme.titleLarge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (final p in players) ...[
                      Expanded(
                        child: _PlayerButton(
                          player: p,
                          selected: _player == p,
                          onTap: () => setState(() => _player = p),
                        ),
                      ),
                      if (p != players.last) const SizedBox(width: 12),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                Text('2. Your rating', style: textTheme.titleLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 1; i <= 5; i++)
                      IconButton(
                        iconSize: 44,
                        tooltip: '$i star${i > 1 ? 's' : ''}',
                        color: Colors.amber.shade700,
                        onPressed: () => setState(() => _rating = i),
                        icon:
                            Icon(i <= _rating ? Icons.star : Icons.star_border),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('3. A comment (optional)', style: textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: _comment,
                  maxLength: 280,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'What do you want to say?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _name,
                  maxLength: 40,
                  decoration: const InputDecoration(
                    labelText: 'Your name (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: canSend ? _send : null,
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18)),
                  child: Text(
                    _sending
                        ? 'Sending...'
                        : _cooldown > 0
                            ? 'Wait $_cooldown s'
                            : 'Send',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 20),
                Text(photoCredits,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall
                        ?.copyWith(color: Theme.of(context).hintColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerButton extends StatelessWidget {
  const _PlayerButton(
      {required this.player, required this.selected, required this.onTap});
  final Player player;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected
              ? player.color.withValues(alpha: 0.25)
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: selected ? player.color : scheme.outlineVariant,
              width: selected ? 5 : 2),
        ),
        child: Column(
          children: [
            // A large portrait photo (4:5) that fills the whole card width.
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Image.asset(player.photo,
                    fit: BoxFit.cover, alignment: Alignment.topCenter),
              ),
            ),
            const SizedBox(height: 10),
            Text(player.name,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Icon(selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? player.color : scheme.outline),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
