import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  final List<Widget> children;

  const SettingsSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: children
            .expand((child) => [child, const Divider(height: 1)])
            .take(children.length * 2 - 1)
            .toList(),
      ),
    );
  }
}