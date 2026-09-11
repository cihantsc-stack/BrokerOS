import 'package:flutter/material.dart';

import '../../../../shared/design/broker_colors.dart';

class ViewModeSelector extends StatelessWidget {
  final bool professionalMode;
  final ValueChanged<bool> onChanged;

  const ViewModeSelector({
    super.key,
    required this.professionalMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              selected: !professionalMode,
              icon: Icons.visibility_outlined,
              label: 'Basit Görünüm',
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ModeButton(
              selected: professionalMode,
              icon: Icons.analytics_outlined,
              label: 'Profesyonel',
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ModeButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? BrokerColors.primary.withValues(alpha: 0.13)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? BrokerColors.primary : BrokerColors.textSoft,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? BrokerColors.primary
                        : BrokerColors.textSoft,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
