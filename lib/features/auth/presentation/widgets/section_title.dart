import 'package:flutter/material.dart';
import 'package:the_boost/core/constants/text_styles.dart';


class SectionTitle extends StatelessWidget {
  final String title;
  final TextAlign? textAlign;
  final Color? color;

  const SectionTitle({
    super.key,
    required this.title,
    this.textAlign,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: textAlign ?? TextAlign.left,
      style: AppTextStyles.h2.copyWith(
        color: color,
      ),
    );
  }
}