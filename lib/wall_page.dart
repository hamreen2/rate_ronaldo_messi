import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';

/// Screen 2: the live results for the projector.
class WallPage extends StatelessWidget {
  const WallPage({super.key});

  @override
  Widget build(BuildContext context) {
    // stream() = SELECT * FROM player_feedback, kept up to date by Realtime.
    final stream = Supabase.instance.client
        .from('player_feedback')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(200);

    // The QR code points to the Rate screen of this same site.
    final sendUrl = Uri.base.replace(fragment: '/').toString();

    return Scaffold(
      backgroundColor: const Color(0xFF14213D),
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Could not load the results:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 22)),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final rows = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(total: rows.length, sendUrl: sendUrl),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final p in players) ...[
                          Expanded(
                            child: _PlayerColumn(
                              player: p,
                              rows: rows
                                  .where((r) => r['player'] == p.name)
                                  .toList(),
                            ),
                          ),
                          if (p != players.last) const SizedBox(width: 24),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(photoCredits,
                      style: TextStyle(color: Colors.white38, fontSize: 13)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.total, required this.sendUrl});
  final int total;
  final String sendUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Ronaldo or Messi?',
            style: TextStyle(
                color: Colors.white, fontSize: 48, fontWeight: FontWeight.w700)),
        const SizedBox(width: 28),
        _Pill(text: total == 1 ? '1 vote' : '$total votes'),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: QrImageView(data: sendUrl, size: 120),
        ),
        const SizedBox(width: 16),
        const Text('Scan to\nvote',
            style: TextStyle(color: Colors.white70, fontSize: 24)),
      ],
    );
  }
}

class _PlayerColumn extends StatelessWidget {
  const _PlayerColumn({required this.player, required this.rows});
  final Player player;
  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    // AVG(rating) and COUNT(*) ... WHERE player = ...
    final average = rows.isEmpty
        ? 0.0
        : rows.map((r) => r['rating'] as int).reduce((a, b) => a + b) /
            rows.length;
    final withComment = rows
        .where((r) => ((r['comment'] as String?) ?? '').trim().isNotEmpty)
        .toList();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: const Color(0xFF1B2A4E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: player.color, width: 4)),
      child: LayoutBuilder(builder: (context, box) {
        // A big photo that runs the full height of the column.
        final photoWidth = (box.maxWidth * 0.4).clamp(160.0, 340.0);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: photoWidth,
              child: Image.asset(player.photo,
                  fit: BoxFit.cover, alignment: Alignment.topCenter),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(player.name,
                        style: TextStyle(
                            color: player.color,
                            fontSize: 36,
                            fontWeight: FontWeight.w700)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(rows.isEmpty ? '-' : average.toStringAsFixed(1),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 64,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text('/ 5',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 26)),
                        ),
                      ],
                    ),
                    Text(rows.length == 1 ? '1 vote' : '${rows.length} votes',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 24)),
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 10),
                      child: Row(
                        children: [
                          for (var i = 1; i <= 5; i++)
                            Icon(
                                i <= average.round() && rows.isNotEmpty
                                    ? Icons.star
                                    : Icons.star_border,
                                color: const Color(0xFFF2A33A),
                                size: 34),
                        ],
                      ),
                    ),
                    Expanded(
                      child: withComment.isEmpty
                          ? const Align(
                              alignment: Alignment.topLeft,
                              child: Text('No comments yet.',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 24)),
                            )
                          : ListView.separated(
                              itemCount: withComment.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) =>
                                  _CommentCard(row: withComment[i]),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
          color: const Color(0xFFF2A33A),
          borderRadius: BorderRadius.circular(999)),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFF14213D),
              fontSize: 26,
              fontWeight: FontWeight.w700)),
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.row});
  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final name = (row['name'] as String?)?.trim();
    final rating = (row['rating'] as int?) ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF22345C),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (name == null || name.isEmpty) ? 'Anonymous' : name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFF5FD4BE),
                      fontSize: 22,
                      fontWeight: FontWeight.w700),
                ),
              ),
              for (var i = 1; i <= 5; i++)
                Icon(i <= rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFF2A33A), size: 20),
            ],
          ),
          const SizedBox(height: 6),
          Text(row['comment'] as String,
              style: const TextStyle(color: Colors.white, fontSize: 22)),
        ],
      ),
    );
  }
}
