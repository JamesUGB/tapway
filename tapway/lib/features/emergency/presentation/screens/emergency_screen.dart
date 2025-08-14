import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tapway/core/utils/logger_config.dart';
import 'package:tapway/features/emergency/data/models/emergency_type.dart';
import 'package:tapway/features/emergency/logic/emergency_controller.dart';
import 'package:tapway/features/emergency/presentation/widgets/emergency_alert_dialog.dart';
import 'package:tapway/features/emergency/presentation/widgets/emergency_panel.dart';
import 'package:tapway/features/emergency/presentation/widgets/sos_button.dart';
import 'package:tapway/routes/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  final EmergencyController _emergencyController =
      Get.find<EmergencyController>();
  bool _isPanelOpen = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() {
      _isPanelOpen = !_isPanelOpen;
    });

    if (_isPanelOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Future<void> _handleEmergencyRequest(EmergencyType type) async {
    _togglePanel();
    
    try {
      final emergency = await _emergencyController.createEmergency(
        type: type,
        description: null,
        mediaFiles: null,
      );

      if (mounted) {
        _showEmergencyAlertDialog(
          context,
          type,
          emergency.location.coordinates.latitude,
          emergency.location.coordinates.longitude,
        );
      }
    } catch (e) {
      LoggerConfig.logger.severe('Error sending emergency request', e);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to send emergency request. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showEmergencyAlertDialog(
      BuildContext context, EmergencyType type, double latitude, double longitude) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return EmergencyAlertDialog(
          type: type,
          latitude: latitude,
          longitude: longitude,
        );
      },
    );
  }

  void _navigateToSettings() {
    Get.toNamed(Routes.settings);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              'TAPWAY',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: Colors.black87,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            leading: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: _navigateToSettings,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.paperPlane),
                  tooltip: 'Notifications',
                  onPressed: () {},
                ),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.red[100]!,
                  Colors.white,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SOSButton(
                    onTap: _togglePanel,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: const Text(
                      'Tap to call for Help',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        EmergencyPanel(
          isPanelOpen: _isPanelOpen,
          animationController: _animationController,
          onTogglePanel: _togglePanel,
          onEmergencyRequest: _handleEmergencyRequest,
        ),
      ],
    );
  }
}