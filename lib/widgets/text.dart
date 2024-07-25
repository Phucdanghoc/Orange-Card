import 'package:flutter/material.dart';
import 'package:orange_card/app_theme.dart';



class TextCustom extends StatelessWidget {
  /// Creates a custom text widget.
  ///
  /// The [text] parameter is the text that will be displayed. The [style] parameter
  /// is the text style to use. The [maxLines] parameter is the maximum number of lines
  /// to display. The [textAlign] parameter is the alignment of the text.
  ///
  /// By default, it uses the text style with body small and bw style.
  const TextCustom(
    this.text, {
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.style,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: AppTheme.title_appbar2,
      textAlign: textAlign,
    );
  }
}
