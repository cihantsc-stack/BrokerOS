import '../events/ai_event.dart';
import '../events/ai_event_bus.dart';
import '../events/ai_event_type.dart';
import 'provider_manager.dart';

class ProviderEventBridge {
  ProviderEventBridge._();

  static final Map<String, ProviderBundle> _lastBundleBySymbol =
      <String, ProviderBundle>{};

  static void publish({
    required String symbol,
    required ProviderBundle bundle,
  }) {
    final previous = _lastBundleBySymbol[symbol];
    final bus = AiEventBus.instance;

    bus.publish(
      AiEvent(
        type: AiEventType.marketUpdated,
        source: 'Provider Manager',
        title: '$symbol piyasa verisi yenilendi',
        description:
            'Fiyat ${bundle.market.price.toStringAsFixed(2)}, '
            'değişim ${_signed(bundle.market.changePercent)}%.',
        payload: <String, Object?>{
          'symbol': symbol,
          'price': bundle.market.price,
          'changePercent': bundle.market.changePercent,
          'volume': bundle.market.volume,
        },
      ),
    );

    if (previous == null ||
        previous.institution.score != bundle.institution.score) {
      bus.publish(
        AiEvent(
          type: AiEventType.smartMoneyChanged,
          source: 'Institution Provider',
          title: '$symbol kurumsal skoru güncellendi',
          description:
              '${previous?.institution.score ?? '-'} → '
              '${bundle.institution.score}',
          payload: <String, Object?>{
            'symbol': symbol,
            'score': bundle.institution.score,
            'netFlow': bundle.institution.netFlow,
          },
        ),
      );
    }

    if (previous == null || previous.news.score != bundle.news.score) {
      bus.publish(
        AiEvent(
          type: AiEventType.newsChanged,
          source: 'News Provider',
          title: '$symbol haber skoru güncellendi',
          description:
              '${previous?.news.score ?? '-'} → ${bundle.news.score} '
              '(${bundle.news.sentiment})',
          payload: <String, Object?>{
            'symbol': symbol,
            'score': bundle.news.score,
            'sentiment': bundle.news.sentiment,
          },
        ),
      );
    }

    if (previous == null ||
        previous.technical.score != bundle.technical.score) {
      bus.publish(
        AiEvent(
          type: AiEventType.momentumChanged,
          source: 'Technical Provider',
          title: '$symbol teknik skoru güncellendi',
          description:
              '${previous?.technical.score ?? '-'} → '
              '${bundle.technical.score}',
          payload: <String, Object?>{
            'symbol': symbol,
            'score': bundle.technical.score,
            'rsi': bundle.technical.rsi,
          },
        ),
      );
    }

    _lastBundleBySymbol[symbol] = bundle;
  }

  static String _signed(double value) {
    return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}';
  }
}
