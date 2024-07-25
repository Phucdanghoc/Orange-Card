import 'package:flutter/material.dart';
import 'package:orange_card/app_theme.dart';


class LoadingIndicatorPage extends StatelessWidget {
  const LoadingIndicatorPage({super.key, this.padding});

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? EdgeInsets.symmetric(vertical: 20),
        child: const LoadingIndicatorWidget(),
      ),
    );
  }
}

class LoadingIndicatorWidget extends StatelessWidget {
  const LoadingIndicatorWidget({
    super.key,
    this.color,
    this.size,
  });

  final Color? color;
  final Size? size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size?.height ?? 25,
      width: size?.width ?? 25,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: color ?? AppTheme.kPrimaryColor,
      ),
    );
  }
}
