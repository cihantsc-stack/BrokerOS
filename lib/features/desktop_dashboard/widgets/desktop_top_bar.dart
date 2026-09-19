import 'package:flutter/material.dart';

class DesktopTopBar extends StatelessWidget {
  const DesktopTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF081210),
        border: Border(bottom: BorderSide(color: Color(0xFF17332B))),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grafiği değil, paranın izini sür.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'CROC AI küresel akışı, teknik yapıyı ve kurumsal parayı birlikte analiz eder.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF71877F), fontSize: 11),
                ),
              ],
            ),
          ),
          _pill(Icons.circle, 'BIST AÇIK  13:42:18', const Color(0xFF70F3AD)),
          const SizedBox(width: 10),
          _icon(Icons.notifications_none_rounded),
          const SizedBox(width: 10),
          _icon(Icons.settings_outlined),
          const SizedBox(width: 14),
          _pill(Icons.person_rounded, 'Cihan Taşçı', Colors.white),
        ],
      ),
    );
  }

  static Widget _icon(IconData icon) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: const Color(0xFF10211C),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFF23483C)),
    ),
    child: Icon(icon, color: const Color(0xFFA0B4AC), size: 20),
  );

  static Widget _pill(IconData icon, String text, Color color) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 13),
    decoration: BoxDecoration(
      color: const Color(0xFF10211C),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFF23483C)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
