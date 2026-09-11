import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../features/intelligence/broker_intelligence_screen.dart';
import '../../../shared/design/broker_colors.dart';

class HomeStockSearch extends StatefulWidget {
  final List<StockAnalysis> stocks;

  const HomeStockSearch({super.key, required this.stocks});

  @override
  State<HomeStockSearch> createState() => _HomeStockSearchState();
}

class _HomeStockSearchState extends State<HomeStockSearch> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<StockAnalysis> _results = <StockAnalysis>[];
  final List<String> _recentSymbols = <String>[];
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _search(String value) {
    final query = _normalize(value);

    setState(() {
      _error = null;

      if (query.isEmpty) {
        _results = <StockAnalysis>[];
        return;
      }

      _results = widget.stocks
          .where((stock) {
            final symbol = _normalize(stock.symbol);
            final company = _normalize(stock.company);

            return symbol.contains(query) || company.contains(query);
          })
          .take(6)
          .toList();
    });
  }

  void _submit() {
    final query = _normalize(_controller.text);

    if (query.isEmpty) {
      setState(() {
        _error = 'Bir hisse kodu veya şirket adı yaz.';
      });
      _focusNode.requestFocus();
      return;
    }

    StockAnalysis? exact;

    for (final stock in widget.stocks) {
      if (_normalize(stock.symbol) == query) {
        exact = stock;
        break;
      }
    }

    if (exact != null) {
      _openStock(exact);
      return;
    }

    if (_results.isNotEmpty) {
      _openStock(_results.first);
      return;
    }

    setState(() {
      _error = 'Bu isimle bir hisse bulunamadı.';
    });
  }

  void _openStock(StockAnalysis stock) {
    final symbol = stock.symbol.toUpperCase();

    setState(() {
      _controller.text = symbol;
      _results = <StockAnalysis>[];
      _error = null;

      _recentSymbols.remove(symbol);
      _recentSymbols.insert(0, symbol);

      if (_recentSymbols.length > 4) {
        _recentSymbols.removeLast();
      }
    });

    _focusNode.unfocus();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BrokerIntelligenceScreen(symbol: symbol),
      ),
    );
  }

  void _clear() {
    _controller.clear();

    setState(() {
      _results = <StockAnalysis>[];
      _error = null;
    });

    _focusNode.requestFocus();
  }

  String _normalize(String value) {
    return value
        .trim()
        .toUpperCase()
        .replaceAll('İ', 'I')
        .replaceAll('Ş', 'S')
        .replaceAll('Ğ', 'G')
        .replaceAll('Ü', 'U')
        .replaceAll('Ö', 'O')
        .replaceAll('Ç', 'C');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrokerColors.cardDeep,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: BrokerColors.primary.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.manage_search_rounded,
                color: BrokerColors.primary,
                size: 23,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hisse Ara',
                      style: TextStyle(
                        color: BrokerColors.textMain,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Hisse kodu veya şirket adıyla hızlıca ara.',
                      style: TextStyle(
                        color: BrokerColors.textSoft,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.search,
            onChanged: _search,
            onSubmitted: (_) => _submit(),
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              hintText: 'Hisse ara: ASELS, THYAO, BFREN...',
              hintStyle: const TextStyle(
                color: BrokerColors.textSoft,
                fontWeight: FontWeight.w600,
              ),
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
                      onPressed: _clear,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: BrokerColors.textSoft,
                      ),
                    ),
                  IconButton(
                    tooltip: 'Hisseyi incele',
                    onPressed: _submit,
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: BrokerColors.primary,
                    ),
                  ),
                ],
              ),
              filled: true,
              fillColor: BrokerColors.primary.withValues(alpha: 0.045),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: BrokerColors.primary.withValues(alpha: 0.18),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: BrokerColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 7),
            Text(
              _error!,
              style: const TextStyle(
                color: BrokerColors.red,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: BrokerColors.primary.withValues(alpha: 0.035),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: BrokerColors.primary.withValues(alpha: 0.10),
                ),
              ),
              child: Column(
                children: _results.map((stock) {
                  final change = stock.dailyChange ?? 0;
                  final positive = change >= 0;
                  final tone = positive ? BrokerColors.green : BrokerColors.red;

                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      dense: true,
                      onTap: () => _openStock(stock),
                      leading: Container(
                        width: 39,
                        height: 39,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: tone.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Text(
                          stock.symbol.substring(
                            0,
                            stock.symbol.length >= 2 ? 2 : stock.symbol.length,
                          ),
                          style: TextStyle(
                            color: tone,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      title: Text(
                        stock.symbol,
                        style: const TextStyle(
                          color: BrokerColors.textMain,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(
                        stock.company,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: BrokerColors.textSoft,
                          fontSize: 10,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${positive ? '+' : ''}'
                            '${change.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: tone,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: BrokerColors.primary,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (_recentSymbols.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  color: BrokerColors.textSoft,
                  size: 15,
                ),
                const SizedBox(width: 5),
                const Text(
                  'Son aramalar',
                  style: TextStyle(
                    color: BrokerColors.textSoft,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _recentSymbols.map((symbol) {
                      return ActionChip(
                        visualDensity: VisualDensity.compact,
                        label: Text(symbol),
                        onPressed: () {
                          final stock = widget.stocks.firstWhere(
                            (item) => item.symbol.toUpperCase() == symbol,
                          );
                          _openStock(stock);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
