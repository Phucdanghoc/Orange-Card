import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:orange_card/app_theme.dart';

import 'gap.dart';

class SelectOptionTileWidget extends StatelessWidget {
  const SelectOptionTileWidget({
    super.key,
    required this.onTap,
    required this.isSelected,
    required this.text,
    this.style,
    this.icon,
    this.color,
  });

  final VoidCallback onTap;
  final bool isSelected;
  final String text;
  final TextStyle? style;
  final String? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Durations.short3,
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(
          vertical: icon != null ? 10 : 15,
          horizontal: 15,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? Color.fromARGB(255, 60, 68, 125)).withOpacity(.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? (color ?? Colors.blue)
                : Color.fromARGB(255, 213, 213, 213).withOpacity(.3),
            width: isSelected ? 2.5 : 2,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: Durations.medium2,
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1000),
                border: Border.all(
                  color: isSelected
                      ? (color ?? Colors.blue)
                      : Color.fromARGB(255, 213, 213, 213).withOpacity(.3),
                  width: isSelected ? 8 : 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
            ),
            const Gap(width: 20),
            Expanded(
              child: Text(
                text,
                style: isSelected
                    ? (style ??
                            TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 0.27,
                              color: Colors.white,
                            ))
                        .copyWith(
                        color: color ?? Colors.blue,
                      )
                    : (style ??
                        TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.27,
                          color: Colors.white,
                        )),
              ),
            ),
            if (icon != null)
              SvgPicture.asset(
                icon!,
                height: 45,
              ),
          ],
        ),
      ),
    );
  }
}
