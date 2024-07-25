import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:orange_card/app_theme.dart';

import 'gap.dart';
import 'text.dart';
import 'unfocus.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, required this.text, this.image, this.info});

  /// Error message.
  final String text;

  /// Must be using `Assets.json` for Lottie package.
  final String? image;

  /// For more info widget that shows under the text widget.
  final Widget? info;

  @override
  Widget build(BuildContext context) {
    return UnfocusArea(
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20).copyWith(top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: 1,
                  child: Lottie.asset(
                    image ?? "/assets/jsons/error.json",
                    width: 180,
                    height: 180,
                  ),
                ),
                Gap(height: 5),
                TextCustom(
                  text,
                  style: TextStyle(
                    // h5 -> headline
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 0.30,
                    color: Color.fromARGB(255, 93, 93, 93),
                  ),
                  maxLines: 5,
                  textAlign: TextAlign.center,
                ),
                if (info != null) ...[
                  Gap(height: 5),
                  info!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
