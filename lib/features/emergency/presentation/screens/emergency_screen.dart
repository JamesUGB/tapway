// lib/features/emergency/presentation/screens/emergency_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tapway/core/utils/logger_config.dart';
import 'package:tapway/features/emergency/data/models/emergency_type.dart';
import 'package:tapway/features/emergency/logic/emergency_controller.dart';
import 'package:tapway/features/emergency/presentation/widgets/emergency_alert_dialog.dart';
import 'package:tapway/features/emergency/presentation/widgets/emergency_panel.dart';
import 'package:tapway/features/emergency/presentation/widgets/sos_button.dart';
import 'package:tapway/features/emergency/presentation/widgets/location_info.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> 
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
  return Stack(
    children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFF5F5F5),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Center content shifted upwards together
                  Center(
                    child: Transform.translate(
                      offset: const Offset(0, -45), // move all content up
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Are you in an \nEmergency?',
                            style: TextStyle(
                              fontSize: 42,
                              color: Color(0xFF212529),
                              fontWeight: FontWeight.bold,
                              height: 1.15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          SOSButton(onTap: _togglePanel),
                          const SizedBox(height: 12),
                          const Text(
                            'Press the Button to Select \nEmergency Rescue',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Location widget pinned at bottom
                  const Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: LocationInfoWidget(
                      currentLocation: 'Odlot Bogo City Waa ka',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Sliding panel overlay
      EmergencyPanel(
        isPanelOpen: _isPanelOpen,
        animationController: _animationController,
        onTogglePanel: _togglePanel,
        onEmergencyRequest: _handleEmergencyRequest,
      ),
    ],
  );
  }

  @override
  bool get wantKeepAlive => true;
}