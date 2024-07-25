import 'package:flutter/material.dart';
import 'package:orange_card/app_theme.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../core/extensions/build_context.dart';
// import '../../core/extensions/color.dart';
// import '../themes/app_color.dart';
// import '../themes/app_text_theme.dart';
import 'text.dart';

enum PushableButtonType { quiz, typing, primary, success, accent, grey, white, disable }

class PushableButton extends StatefulWidget {
  const PushableButton({
    super.key,
    required this.onPressed,
    this.child,
    this.type = PushableButtonType.primary,
    this.quiz = PushableButtonType.quiz,
    this.typing = PushableButtonType.typing,
    this.text = 'Button',
    this.height = 52,
    this.width,
    this.elevation = 5.0,
    this.borderRadius = 10,
    this.duration = 350,
    this.textColor,
    this.textStyle,
    this.borderside = true,
  });

  final Widget? child;
  final String text;
  final double height;
  final double? width;
  final double elevation;
  final Color? textColor;
  final double borderRadius;
  final int duration;
  final TextStyle? textStyle;
  final PushableButtonType type;
  final PushableButtonType quiz;
  final PushableButtonType typing;
  final VoidCallback onPressed;
  final bool borderside;

  @override
  State<PushableButton> createState() => _PushableButtonState();
}

class _PushableButtonState extends State<PushableButton> {
  late double _elevation;
  late double _borderRadiusFixed;
  @override
  void initState() {
    super.initState();
    _elevation = widget.elevation;
    _borderRadiusFixed = widget.borderRadius + (widget.borderRadius / 2 - 1);
  }

  Decoration? get _boxDecoration {
    final backgroundColor = switch (widget.type) {
      PushableButtonType.primary => AppTheme.kPrimaryColor,
      PushableButtonType.success => Colors.green,
      PushableButtonType.accent => Colors.red,
      PushableButtonType.grey => Colors.grey,
      PushableButtonType.white => AppTheme.dismissibleBackground,
      PushableButtonType.disable => Colors.grey,
      PushableButtonType.quiz => Colors.purpleAccent,
      PushableButtonType.typing => Colors.blueAccent,
    };
    return BoxDecoration(
      color: backgroundColor,
      border: widget.borderside
          ? Border(
              bottom: BorderSide(
                color: widget.type == PushableButtonType.disable
                    ? backgroundColor
                    : Color.fromARGB(255, 118, 116, 108),
                width: _elevation,
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _elevation = 0.0),
      onTapUp: (_) => setState(() => _elevation = widget.elevation),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.borderRadius),
          bottom: Radius.circular(_borderRadiusFixed),
        ),
        child: AnimatedContainer(
          height: widget.height,
          width: widget.width,
          curve: Curves.fastOutSlowIn,
          duration: Duration(milliseconds: widget.duration),
          decoration: _boxDecoration,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: widget.width == null ? 20 : 0),
              child: widget.child ??
                  TextCustom(
                    widget.text,
                    style: widget.textStyle ??
                        TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ).copyWith(
                          color: widget.textColor ??
                              (widget.type == PushableButtonType.grey ||
                                      widget.type == PushableButtonType.white
                                  ? AppTheme.dark_grey
                                  : Colors.white),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
