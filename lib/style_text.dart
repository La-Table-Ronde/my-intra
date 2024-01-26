import 'package:flutter/material.dart';

class StyledTextWidget extends StatelessWidget {
  final String text;
  final TextStyle defaultStyle;
  final List<TextStyle> wordStyles;

  const StyledTextWidget({
    super.key,
    required this.text,
    required this.defaultStyle,
    required this.wordStyles,
  });

  @override
  Widget build(BuildContext context) {
    List<String> words = text.split(" ");

    return RichText(
      text: TextSpan(
        children: [
          for (int i = 0; i < words.length; i++)
            TextSpan(
              text: wordStyles.length + 1 < words.length
                  ? words[i]
                  : "${words[i]} ",
              style: wordStyles.length > i ? wordStyles[i] : defaultStyle,
            ),
        ],
      ),
    );
  }
}
