// emergency_panel.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:tapway/features/emergency/data/models/emergency_type.dart';

class EmergencyPanel extends StatelessWidget {
  final bool isPanelOpen;
  final AnimationController animationController;
  final VoidCallback onTogglePanel;
  final Function(EmergencyType) onEmergencyRequest;
  final double panelWidth;

  const EmergencyPanel({
    super.key,
    required this.isPanelOpen,
    required this.animationController,
    required this.onTogglePanel,
    required this.onEmergencyRequest,
    this.panelWidth = 300,
  });

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );

    final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    return Stack(
      children: [
        // Backdrop blur overlay
        AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Visibility(
              visible: isPanelOpen,
              child: Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Opacity(
                  opacity: opacityAnimation.value,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 5 * opacityAnimation.value,
                      sigmaY: 5 * opacityAnimation.value,
                    ),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3 * opacityAnimation.value),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Side panel
        AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Visibility(
              visible: isPanelOpen,
              child: Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onTogglePanel,
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(panelWidth * slideAnimation.value, 0),
                      child: SizedBox(
                        width: panelWidth,
                        height: MediaQuery.of(context).size.height,
                        child: Material(
                          elevation: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: MediaQuery.of(context).padding.top),
                                _buildPanelHeader(),
                                Expanded(
                                  child: _buildPanelContent(),
                                ),
                                _buildPanelFooter(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPanelHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.red[600],
        border: Border(
          bottom: BorderSide(
            color: Colors.red[700]!,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onTogglePanel,
          ),
          const Expanded(
            child: Center(
              child: Text(
                'EMERGENCY RESCUE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPanelContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildEmergencyOption(
            icon: Icons.medical_services,
            label: 'MEDICAL EMERGENCY',
            description: 'Ambulance & Medical Care',
            color: Colors.red[600]!,
            onTap: () => onEmergencyRequest(EmergencyType.medical),
          ),
          const SizedBox(height: 20),
          _buildEmergencyOption(
            icon: Icons.local_police,
            label: 'POLICE ASSISTANCE',
            description: 'Law Enforcement Help',
            color: Colors.blue[700]!,
            isHighlighted: true,
            onTap: () => onEmergencyRequest(EmergencyType.police),
          ),
          const SizedBox(height: 20),
          _buildEmergencyOption(
            icon: Icons.fire_extinguisher,
            label: 'FIRE EMERGENCY',
            description: 'Fire & Rescue Services',
            color: Colors.orange[700]!,
            onTap: () => onEmergencyRequest(EmergencyType.fire),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: const Text(
        'In case of immediate danger, call 911',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildEmergencyOption({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted ? color : Colors.grey[300]!,
            width: isHighlighted ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}