import '../models/flow_context_input.dart';

abstract interface class FlowContextProvider {
  Future<FlowContextInput> fetch(String symbol);
}

class UnavailableFlowContextProvider implements FlowContextProvider {
  const UnavailableFlowContextProvider();

  @override
  Future<FlowContextInput> fetch(String symbol) async {
    return FlowContextInput(
      symbol: symbol.trim().toUpperCase().replaceAll('.IS', ''),
      institutionalDataAvailable: false,
      fundDataAvailable: false,
      crossAssetDataAvailable: false,
      observedAt: DateTime.now(),
    );
  }
}
