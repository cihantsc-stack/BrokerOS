import 'copilot_message.dart';

class CopilotResponse {
  final CopilotMessage shortMessage;
  final CopilotMessage standardMessage;

  const CopilotResponse({
    required this.shortMessage,
    required this.standardMessage,
  });
}
