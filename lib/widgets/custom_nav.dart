import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class CustomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar>
    with TickerProviderStateMixin {
  // Animation controllers for each tab
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _bounceAnimations;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _animationControllers = List.generate(
      5, // Total number of tabs including more options
      (index) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
    );

    // Scale animations for icons
    _scaleAnimations = _animationControllers.map((controller) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.4)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.4, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 50,
        ),
      ]).animate(controller);
    }).toList();

    // Bounce animations for selected indicator
    _bounceAnimations = _animationControllers.map((controller) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 100,
        ),
      ]).animate(controller);
    }).toList();

    // Start the animation for the current tab
    if (widget.currentIndex >= 0 &&
        widget.currentIndex < _animationControllers.length) {
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(CustomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the tab changed, animate the new tab
    if (widget.currentIndex != oldWidget.currentIndex) {
      // Reset old tab animation
      if (oldWidget.currentIndex >= 0 &&
          oldWidget.currentIndex < _animationControllers.length) {
        _animationControllers[oldWidget.currentIndex].reset();
      }

      // Start new tab animation
      if (widget.currentIndex >= 0 &&
          widget.currentIndex < _animationControllers.length) {
        _animationControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    // Dispose all animation controllers
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final Color accentColor = themeProvider.accentOptions
        .firstWhere((option) => option.id == themeProvider.accentId)
        .color;

    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.notes_rounded,
                label: "Notes",
                index: 0,
                accentColor: accentColor,
              ),
              _buildNavItem(
                context,
                icon: Icons.book_rounded,
                label: "Diary",
                index: 1,
                accentColor: accentColor,
              ),
              _buildMiddleButton(context, accentColor),
              _buildNavItem(
                context,
                icon: Icons.checklist_rounded,
                label: "Tasks",
                index: 3,
                accentColor: accentColor,
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_rounded,
                label: "Settings",
                index: 4,
                accentColor: accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required Color accentColor,
  }) {
    final isSelected = widget.currentIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            HapticFeedback.selectionClick();
            widget.onTap(index);
          }
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: isSelected ? _scaleAnimations[index].value : 1.0,
                    child: child,
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? accentColor
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedBuilder(
                animation: _bounceAnimations[index],
                builder: (context, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3,
                    width: isSelected ? 20 * _bounceAnimations[index].value : 0,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiddleButton(BuildContext context, Color accentColor) {
    // Check if camera tab is selected
    final isSelected = widget.currentIndex == 2;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap(2);
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(33),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            builder: (context, double value, child) {
              return Transform.scale(
                scale: isSelected ? 1.0 + (0.1 * value) : 1.0,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        accentColor,
                        accentColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.4),
                        blurRadius: isSelected ? 15 * value : 10,
                        spreadRadius: isSelected ? 2 * value : 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 28,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
