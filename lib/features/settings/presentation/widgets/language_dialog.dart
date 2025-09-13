import 'package:flutter/material.dart';

class LanguageDialog extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onLanguageSelected;

  const LanguageDialog({
    super.key,
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final languages = ['English', 'Spanish', 'French', 'German'];

    return AlertDialog(
      title: const Text('Select Language'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: languages.length,
          itemBuilder: (context, index) {
            return RadioListTile(
              title: Text(languages[index]),
              value: languages[index],
              groupValue: currentLanguage,
              onChanged: (value) {
                onLanguageSelected(value.toString());
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}