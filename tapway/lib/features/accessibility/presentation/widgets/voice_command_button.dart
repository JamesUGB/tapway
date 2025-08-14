//C:\Users\Zino\Documents\tapway\lib\features\accessibility\presentation\widgets\voice_command_button.dart
import 'package:flutter/material.dart';

class VoiceCommandButton extends StatelessWidget {
  const VoiceCommandButton({super.key});  // Fixed super parameter

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FloatingActionButton.extended(
        icon: const Icon(Icons.mic),
        label: const Text('Voice Command'),
        onPressed: () {
          // Activate voice commands
          // context.read<VoiceCommandService>().listen();
        },
      ),
    );
  }
}