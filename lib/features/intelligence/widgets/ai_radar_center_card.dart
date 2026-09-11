import 'package:flutter/material.dart';

import '../../../core/radar/data/bist_symbol_catalog.dart';
import '../../../core/radar/models/radar_opportunity.dart';
import '../../../core/radar/services/radar_service.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

enum _RadarFilter { all, strong, positive, watch, favorites }

class AiRadarCenterCard extends StatefulWidget {
  final String selectedSymbol;
  final ValueChanged<String> onSymbolSelected;

  const AiRadarCenterCard({
    super.key,
    required this.selectedSymbol,
    required this.onSymbolSelected,
  });

  @override
  State<AiRadarCenterCard> createState() => _AiRadarCenterCardState();
}

class _AiRadarCenterCardState extends State<AiRadarCenterCard> {
  final TextEditingController _controller = TextEditingController();

  late final List<RadarOpportunity> _opportunities;
  final Set<String> _favorites = <String>{};
  final List<String> _recentSearches = <String>[];

  List<String> _suggestions = <String>[];
  _RadarFilter _filter = _RadarFilter.all;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _opportunities = RadarService.instance.scan(limit: 10);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<RadarOpportunity> get _filteredOpportunities {
    return _opportunities
        .where((item) {
          switch (_filter) {
            case _RadarFilter.all:
              return true;
            case _RadarFilter.strong:
              return item.decision.contains('GÜÇLÜ AL');
            case _RadarFilter.positive:
              return item.decision.contains('AL') &&
                  !item.decision.contains('GÜÇLÜ AL');
            case _RadarFilter.watch:
              return item.decision.contains('İZLE') ||
                  item.decision.contains('TEYİT');
            case _RadarFilter.favorites:
              return _favorites.contains(item.symbol);
          }
        })
        .take(5)
        .toList();
  }

  int _countFor(_RadarFilter filter) {
    return _opportunities.where((item) {
      switch (filter) {
        case _RadarFilter.all:
          return true;
        case _RadarFilter.strong:
          return item.decision.contains('GÜÇLÜ AL');
        case _RadarFilter.positive:
          return item.decision.contains('AL') &&
              !item.decision.contains('GÜÇLÜ AL');
        case _RadarFilter.watch:
          return item.decision.contains('İZLE') ||
              item.decision.contains('TEYİT');
        case _RadarFilter.favorites:
          return _favorites.contains(item.symbol);
      }
    }).length;
  }

  void _search(String value) {
    final query = value.trim().toUpperCase();
    setState(() {
      _suggestions = query.isEmpty
          ? <String>[]
          : RadarService.instance.searchSymbols(query).take(5).toList();
      _errorMessage = null;
    });
  }

  void _openTypedSymbol() {
    final symbol = _controller.text.trim().toUpperCase();
    if (symbol.isEmpty) {
      setState(() {
        _errorMessage = 'Bir hisse kodu yaz.';
      });
      return;
    }
    _selectSymbol(symbol);
  }

  void _selectSymbol(String symbol) {
    final normalized = symbol.trim().toUpperCase();
    _controller.text = normalized;

    setState(() {
      _suggestions = <String>[];
      _errorMessage = null;
      _recentSearches.remove(normalized);
      _recentSearches.insert(0, normalized);
      if (_recentSearches.length > 4) {
        _recentSearches.removeLast();
      }
    });

    widget.onSymbolSelected(normalized);
  }

  void _toggleFavorite(String symbol) {
    setState(() {
      if (!_favorites.add(symbol)) {
        _favorites.remove(symbol);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filteredOpportunities;

    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hisse Ara',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            onChanged: _search,
            onSubmitted: (_) => _openTypedSymbol(),
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              hintText: 'Hisse ara: ASELS',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: BrokerColors.primary,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Temizle',
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _suggestions = <String>[];
                          _errorMessage = null;
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  IconButton(
                    tooltip: 'Hisseyi aç',
                    onPressed: _openTypedSymbol,
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ],
              ),
              filled: true,
              fillColor: BrokerColors.primary.withValues(alpha: 0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: BrokerColors.primary.withValues(alpha: 0.14),
                ),
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: BrokerColors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (_suggestions.isNotEmpty)
            _SuggestionBox(
              suggestions: _suggestions,
              onSelected: _selectSymbol,
            ),
          if (_recentSearches.isNotEmpty) ...[
            const SizedBox(height: 9),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: _recentSearches.map((symbol) {
                return ActionChip(
                  avatar: const Icon(Icons.history_rounded, size: 16),
                  label: Text(symbol),
                  onPressed: () => _selectSymbol(symbol),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 18),
          const Row(
            children: [
              Icon(Icons.radar_rounded, color: BrokerColors.primary, size: 27),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Bugünün Radarı',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Hisseyi bul, durumunu gör ve detayına geç.',
            style: TextStyle(color: BrokerColors.textSoft),
          ),
          const SizedBox(height: 10),
          const _MarketSessionBanner(),
          const SizedBox(height: 13),
          const SizedBox(height: 16),
          _RadarSummary(
            strong: _countFor(_RadarFilter.strong),
            positive: _countFor(_RadarFilter.positive),
            watch: _countFor(_RadarFilter.watch),
          ),
          const SizedBox(height: 13),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tümü',
                  count: _countFor(_RadarFilter.all),
                  selected: _filter == _RadarFilter.all,
                  onTap: () => setState(() => _filter = _RadarFilter.all),
                ),
                _FilterChip(
                  label: 'Çok Güçlü',
                  count: _countFor(_RadarFilter.strong),
                  selected: _filter == _RadarFilter.strong,
                  onTap: () => setState(() => _filter = _RadarFilter.strong),
                ),
                _FilterChip(
                  label: 'Olumlu',
                  count: _countFor(_RadarFilter.positive),
                  selected: _filter == _RadarFilter.positive,
                  onTap: () => setState(() => _filter = _RadarFilter.positive),
                ),
                _FilterChip(
                  label: 'İzle',
                  count: _countFor(_RadarFilter.watch),
                  selected: _filter == _RadarFilter.watch,
                  onTap: () => setState(() => _filter = _RadarFilter.watch),
                ),
                _FilterChip(
                  label: 'Favoriler',
                  count: _countFor(_RadarFilter.favorites),
                  selected: _filter == _RadarFilter.favorites,
                  onTap: () => setState(() => _filter = _RadarFilter.favorites),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Text(
            '${visible.length} hisse gösteriliyor',
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (visible.isEmpty)
            const _EmptyRadarState()
          else
            ...visible.asMap().entries.map(
              (entry) => _RadarChoiceCard(
                rank: entry.key + 1,
                opportunity: entry.value,
                selected:
                    widget.selectedSymbol.toUpperCase() ==
                    entry.value.symbol.toUpperCase(),
                favorite: _favorites.contains(entry.value.symbol),
                onFavorite: () => _toggleFavorite(entry.value.symbol),
                onTap: () => _selectSymbol(entry.value.symbol),
              ),
            ),
          if (_favorites.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              'Favoriler: ${_favorites.join(', ')}',
              style: const TextStyle(
                color: BrokerColors.textSoft,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MarketSessionBanner extends StatelessWidget {
  const _MarketSessionBanner();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final minutes = now.hour * 60 + now.minute;
    final weekdayOpen =
        now.weekday >= DateTime.monday && now.weekday <= DateTime.friday;
    final sessionOpen = weekdayOpen && minutes >= 600 && minutes < 1080;

    final tone = sessionOpen ? BrokerColors.green : BrokerColors.orange;
    final title = sessionOpen ? 'Piyasa açık' : 'Piyasa kapalı';
    final explanation = sessionOpen
        ? 'Radar gün içindeki değişimleri izliyor.'
        : 'Gösterilen veriler son kayıtlı durumu temsil eder.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            sessionOpen ? Icons.circle : Icons.schedule_rounded,
            size: sessionOpen ? 10 : 18,
            color: tone,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title • $explanation',
              style: TextStyle(
                color: tone,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarSummary extends StatelessWidget {
  final int strong;
  final int positive;
  final int watch;

  const _RadarSummary({
    required this.strong,
    required this.positive,
    required this.watch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryItem(
          value: strong,
          label: 'Çok Güçlü',
          tone: BrokerColors.green,
        ),
        const SizedBox(width: 7),
        _SummaryItem(
          value: positive,
          label: 'Olumlu',
          tone: BrokerColors.primary,
        ),
        const SizedBox(width: 7),
        _SummaryItem(value: watch, label: 'İzle', tone: BrokerColors.orange),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final int value;
  final String label;
  final Color tone;

  const _SummaryItem({
    required this.value,
    required this.label,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: tone,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                color: BrokerColors.textSoft,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => onTap(),
        label: Text('$label ($count)'),
      ),
    );
  }
}

class _SuggestionBox extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  const _SuggestionBox({required this.suggestions, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 7),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: suggestions.map((symbol) {
          return Material(
            color: Colors.transparent,
            child: ListTile(
              dense: true,
              title: Text(
                symbol,
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text(
                BistSymbolCatalog.companyOf(symbol),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: BrokerColors.textSoft),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: BrokerColors.primary,
              ),
              onTap: () => onSelected(symbol),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RadarChoiceCard extends StatelessWidget {
  final int rank;
  final RadarOpportunity opportunity;
  final bool selected;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  const _RadarChoiceCard({
    required this.rank,
    required this.opportunity,
    required this.selected,
    required this.favorite,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final language = _languageFor(opportunity.decision);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: language.tone.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? language.tone.withValues(alpha: 0.55)
              : language.tone.withValues(alpha: 0.14),
          width: selected ? 1.7 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 3,
          ),
          leading: CircleAvatar(
            backgroundColor: language.tone.withValues(alpha: 0.12),
            child: Text(
              '$rank',
              style: TextStyle(
                color: language.tone,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          title: Text(
            opportunity.symbol,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Text(
            '${language.label} • ${language.action}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: language.tone,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing: IconButton(
            onPressed: onFavorite,
            icon: Icon(
              favorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: favorite ? BrokerColors.orange : BrokerColors.textSoft,
            ),
          ),
        ),
      ),
    );
  }

  static _RadarLanguage _languageFor(String decision) {
    if (decision.contains('GÜÇLÜ AL')) {
      return const _RadarLanguage(
        label: 'Çok Güçlü',
        action: 'Kademeli alım için incele',
        tone: BrokerColors.green,
      );
    }
    if (decision.contains('AL')) {
      return const _RadarLanguage(
        label: 'Olumlu',
        action: 'Giriş seviyesini kontrol et',
        tone: BrokerColors.green,
      );
    }
    if (decision.contains('İZLE')) {
      return const _RadarLanguage(
        label: 'İzle',
        action: 'Güçlenmesini bekle',
        tone: BrokerColors.primary,
      );
    }
    if (decision.contains('TEYİT')) {
      return const _RadarLanguage(
        label: 'Bekle',
        action: 'Henüz acele etme',
        tone: BrokerColors.orange,
      );
    }
    return const _RadarLanguage(
      label: 'Riskli',
      action: 'Şimdilik uzak dur',
      tone: BrokerColors.red,
    );
  }
}

class _EmptyRadarState extends StatelessWidget {
  const _EmptyRadarState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.filter_alt_off_rounded,
            color: BrokerColors.textSoft,
            size: 28,
          ),
          SizedBox(height: 7),
          Text(
            'Bu filtrede uygun hisse bulunamadı.',
            style: TextStyle(
              color: BrokerColors.textSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarLanguage {
  final String label;
  final String action;
  final Color tone;

  const _RadarLanguage({
    required this.label,
    required this.action,
    required this.tone,
  });
}
