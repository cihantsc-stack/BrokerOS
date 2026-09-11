import 'package:flutter/material.dart';

import '../../../core/funds/data_sources/tefas_fund_data_source.dart';

class FundFinderSheet extends StatefulWidget {
  final TefasFundDataSource dataSource;
  final ValueChanged<FundSearchItem> onSelected;

  const FundFinderSheet({
    super.key,
    required this.dataSource,
    required this.onSelected,
  });

  @override
  State<FundFinderSheet> createState() => _FundFinderSheetState();
}

class _FundFinderSheetState extends State<FundFinderSheet> {
  String _horizon = '3-12 AY';
  String _risk = 'ORTA';
  String _goal = 'DENGELI BUYUME';
  bool _loading = false;
  String? _summary;
  List<FundSearchItem> _results = const <FundSearchItem>[];

  String _queryForSelection() {
    if (_goal == 'PARAYI KORU' || _horizon == '0-3 AY') {
      return 'PARA PIYASASI';
    }
    if (_risk == 'DUSUK') {
      return 'BORCLANMA ARACLARI';
    }
    if (_risk == 'YUKSEK' && _horizon == '1 YIL+') {
      return 'HISSE SENEDI';
    }
    return 'DEGISKEN';
  }

  String _categoryLabel(String query) {
    switch (query) {
      case 'PARA PIYASASI':
        return 'Para piyasası fonları';
      case 'BORCLANMA ARACLARI':
        return 'Borçlanma araçları fonları';
      case 'HISSE SENEDI':
        return 'Hisse senedi fonları';
      default:
        return 'Değişken fonlar';
    }
  }

  Future<void> _findCandidates() async {
    final query = _queryForSelection();
    setState(() {
      _loading = true;
      _summary = null;
      _results = const <FundSearchItem>[];
    });

    final results = await widget.dataSource.searchFunds(query, limit: 8);
    if (!mounted) return;

    setState(() {
      _loading = false;
      _results = results;
      _summary = results.isEmpty
          ? 'Bu seçim için gerçek TEFAS kataloğunda aday bulunamadı.'
          : '${_categoryLabel(query)} içinden ${results.length} gerçek TEFAS adayı bulundu.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFF020605),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF315346),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'CROC bana fon bulsun',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Üç basit soruya cevap ver. CROC önce sana uygun fon türünü daraltsın, sonra gerçek TEFAS fonlarını göstersin.',
                style: TextStyle(color: Color(0xFF91A69D), height: 1.4),
              ),
              const SizedBox(height: 22),
              _question(
                'Paraya ne kadar süre dokunmayacaksın?',
                ['0-3 AY', '3-12 AY', '1 YIL+'],
                _horizon,
                (value) => setState(() => _horizon = value),
              ),
              const SizedBox(height: 18),
              _question(
                'Dalgalanma seni ne kadar rahatsız eder?',
                ['DUSUK', 'ORTA', 'YUKSEK'],
                _risk,
                (value) => setState(() => _risk = value),
              ),
              const SizedBox(height: 18),
              _question(
                'Ana hedefin ne?',
                ['PARAYI KORU', 'DENGELI BUYUME', 'BUYUME'],
                _goal,
                (value) => setState(() => _goal = value),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _findCandidates,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1D7A50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    _loading ? 'Gerçek fonlar taranıyor...' : 'Bana uygun adayları bul',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Bu ilk eleme, fon adındaki gerçek kategori bilgisine göre yapılır. Performans sıralaması veya yatırım tavsiyesi değildir. Seçtiğin fon açıldığında gerçek TEFAS geçmişi ve risk metrikleri ayrıca analiz edilir.',
                style: TextStyle(
                  color: Color(0xFFFFC66D),
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
              if (_summary != null) ...[
                const SizedBox(height: 20),
                Text(
                  _summary!,
                  style: const TextStyle(
                    color: Color(0xFF70F4AD),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
              if (_results.isNotEmpty) ...[
                const SizedBox(height: 12),
                ..._results.map(_resultTile),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _question(
    String title,
    List<String> options,
    String selected,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final active = selected == option;
            return ChoiceChip(
              selected: active,
              onSelected: (_) => onChanged(option),
              label: Text(option),
              labelStyle: TextStyle(
                color: active ? const Color(0xFF04140D) : const Color(0xFFD6E1DC),
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
              selectedColor: const Color(0xFF70F4AD),
              backgroundColor: const Color(0xFF0A2118),
              side: const BorderSide(color: Color(0xFF1E5C43)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _resultTile(FundSearchItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF07130F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E5C43)),
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(context).pop();
          widget.onSelected(item);
        },
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF123A2A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            item.fundCode,
            style: const TextStyle(
              color: Color(0xFF70F4AD),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        title: Text(
          item.fundName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        subtitle: Text(
          item.isFreeFund ? 'SERBEST FON' : 'TEFAS',
          style: TextStyle(
            color: item.isFreeFund
                ? const Color(0xFFFFC66D)
                : const Color(0xFF91A69D),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF668077),
        ),
      ),
    );
  }
}
