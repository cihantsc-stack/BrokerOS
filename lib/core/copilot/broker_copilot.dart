import '../consensus/consensus_result.dart';
import '../consensus/consensus_vote.dart';
import 'copilot_message.dart';
import 'copilot_response.dart';

class BrokerCopilot {
  BrokerCopilot._();

  static final BrokerCopilot instance = BrokerCopilot._();

  CopilotResponse explain(ConsensusResult result) {
    final strongest = [...result.votes]
      ..sort((a, b) => b.weightedScore.abs().compareTo(a.weightedScore.abs()));

    final lead = strongest.first;
    final second = strongest.length > 1 ? strongest[1] : strongest.first;

    return CopilotResponse(
      shortMessage: CopilotMessage(
        title: 'CROC AI Kararı',
        body:
            '${result.finalSignal.label}. Güven %${result.confidence}, risk ${result.riskLevel.toLowerCase()}.',
      ),
      standardMessage: CopilotMessage(
        title: 'Broker Copilot Yorumu',
        body:
            '${lead.agent} ve ${second.agent} karar üzerinde en yüksek etkiye sahip. '
            '${lead.reason} Bu nedenle CROC AI kararı ${result.finalSignal.label}.',
      ),
    );
  }
}
