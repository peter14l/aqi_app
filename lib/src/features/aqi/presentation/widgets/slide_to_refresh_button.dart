import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';

class SlideToRefreshButton extends StatefulWidget {
  final VoidCallback onRefresh;

  const SlideToRefreshButton({super.key, required this.onRefresh});

  @override
  State<SlideToRefreshButton> createState() => _SlideToRefreshButtonState();
}

class _SlideToRefreshButtonState extends State<SlideToRefreshButton>
    with SingleTickerProviderStateMixin {
  double _dragValue = 0.0;
  final double _buttonSize = 64.0;
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final maxDrag = width - _buttonSize - 8; // 8 is padding

        return Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Stack(
            children: [
              // Text
              Center(
                child: AnimatedOpacity(
                  opacity: _dragValue > 0.5 ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    'Refresh  > > >',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.greenText,
                    ),
                  ),
                ),
              ),

              // Slider Button
              Positioned(
                left: 8 + (maxDrag * _dragValue),
                top: 8,
                bottom: 8,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isRefreshing) return;
                    setState(() {
                      double newValue =
                          _dragValue + (details.delta.dx / maxDrag);
                      _dragValue = newValue.clamp(0.0, 1.0);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isRefreshing) return;
                    if (_dragValue > 0.8) {
                      // Trigger refresh
                      setState(() {
                        _dragValue = 1.0;
                        _isRefreshing = true;
                      });
                      widget.onRefresh();
                      // Reset after delay
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            _dragValue = 0.0;
                            _isRefreshing = false;
                          });
                        }
                      });
                    } else {
                      // Snap back
                      setState(() {
                        _dragValue = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: _buttonSize,
                    height: _buttonSize,
                    decoration: const BoxDecoration(
                      color: AppColors.greenBackground,
                      shape: BoxShape.circle,
                    ),
                    child:
                        _isRefreshing
                            ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                            : const Icon(
                              Icons.arrow_forward,
                              color: Colors.black,
                            ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
