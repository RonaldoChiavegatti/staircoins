import 'package:flutter/material.dart';
import 'package:staircoins/theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final bool isOutlined;
  final Widget? child;

  const GradientButton({
    Key? key,
    this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 50.0,
    this.isOutlined = false,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: isOutlined ? null : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(25),
        border: isOutlined
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading || onPressed == null ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : child ?? (text != null
                ? Text(
                    text!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isOutlined ? AppTheme.primaryColor : Colors.white,
                    ),
                  )
                : const SizedBox()),
      ),
    );
  }
} 