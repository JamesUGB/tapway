import 'package:tapway/features/settings/data/repositories/settings_repository.dart';
import 'package:tapway/features/settings/data/models/settings_model.dart';

class SettingsOrchestrator {
  final SettingsRepository _settingsRepository;

  SettingsOrchestrator(this._settingsRepository);

  Future<SettingsModel> loadSettings() async {
    return await _settingsRepository.getSettings();
  }

  Future<void> updateSettings(SettingsModel settings) async {
    await _settingsRepository.saveSettings(settings);
  }
}