import 'package:flutter/material.dart';

import '../services/global_pulse_service.dart';

class GlobalPulseCard extends StatefulWidget {
  const GlobalPulseCard({super.key});

  @override
  State<GlobalPulseCard> createState() => _GlobalPulseCardState();
}

class _GlobalPulseCardState extends State<GlobalPulseCard> {
  late Future<GlobalPulseSnapshot> _future;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _future = GlobalPulseService.instance.fetch();
  }

  Future<void> _refresh() async {
    if (_refreshing) return;

    setState(() {
      _refreshing = true;
      _future = GlobalPulseService.instance.fetch(forceRefresh: true);
    });

    try {
      await _future;
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
        });
      }
    }
  }

  Color _tone(int score) {
    if (score >= 72) return const Color(0xFF70F4AD);
    if (score <= 38) return const Color(0xFFFF7E88);
    return const Color(0xFFFFC857);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF06130F),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF173D30)),
      ),
      child: FutureBuilder<GlobalPulseSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const _GlobalPulseLoading();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _GlobalPulseError(onRetry: _refresh);
          }

          final pulse = snapshot.data!;
          final tone = _tone(pulse.score);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.public_rounded,
                    color: Color(0xFF70F4AD),
                    size: 18,
                  ),
                  const SizedBox(width: 7),
                  const Expanded(
                    child: Text(
                      'GLOBAL NABIZ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _refreshing ? null : _refresh,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: _refreshing
                          ? const SizedBox(
                              width: 13,
                              height: 13,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF70F4AD),
                              ),
                            )
                          : const Icon(
                              Icons.refresh_rounded,
                              color: Color(0xFF70F4AD),
                              size: 15,
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${pulse.score}',
                    style: TextStyle(
                      color: tone,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      pulse.regime,
                      style: TextStyle(
                        color: tone,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                pulse.comment,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFA2B4AC),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Expanded(
                child: Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: pulse.items
                      .take(6)
                      .map((item) => _PulseChip(item: item))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PulseChip extends StatelessWidget {
  final GlobalPulseItem item;

  const _PulseChip({required this.item});

  @override
  Widget build(BuildContext context) {
    final positive = item.inverse
        ? item.changePercent <= 0
        : item.changePercent >= 0;

    final tone = positive ? const Color(0xFF70F4AD) : const Color(0xFFFF7E88);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1E17),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFF173D30)),
      ),
      child: Text(
        '${item.label} '
        '${item.changePercent >= 0 ? '+' : ''}'
        '${item.changePercent.toStringAsFixed(1)}%',
        style: TextStyle(
          color: tone,
          fontSize: 7.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _GlobalPulseLoading extends StatelessWidget {
  const _GlobalPulseLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.public_rounded, color: Color(0xFF70F4AD), size: 18),
            SizedBox(width: 7),
            Text(
              'GLOBAL NABIZ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        Spacer(),
        LinearProgressIndicator(
          color: Color(0xFF70F4AD),
          backgroundColor: Color(0xFF123025),
        ),
        SizedBox(height: 7),
        Text(
          'Global piyasalar taranıyor...',
          style: TextStyle(color: Color(0xFF83988E), fontSize: 8.5),
        ),
        Spacer(),
      ],
    );
  }
}

class _GlobalPulseError extends StatelessWidget {
  final VoidCallback onRetry;

  const _GlobalPulseError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.public_off_rounded, color: Color(0xFFFFC857), size: 18),
            SizedBox(width: 7),
            Text(
              'GLOBAL NABIZ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const Spacer(),
        const Text(
          'Global veri şu an alınamadı.',
          style: TextStyle(
            color: Color(0xFFFFC857),
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 14),
          label: const Text('Tekrar dene'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF70F4AD),
            padding: EdgeInsets.zero,
            textStyle: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
