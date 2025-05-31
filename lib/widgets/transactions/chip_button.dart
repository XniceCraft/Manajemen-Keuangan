import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';


class ChipButton extends StatelessWidget {
  final String name;
  final Function() onPressed;
  final bool isSelected;

  const ChipButton({super.key, required this.name, required this.onPressed, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor:
            isSelected
                ? AppTheme.primaryColor.withAlpha(51)
                : AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          name,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
