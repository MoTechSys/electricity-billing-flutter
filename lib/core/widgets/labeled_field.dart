import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';

/// حقل نصي بعنوان — يوحّد شكل النماذج في كل التطبيق.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.required = false,
    this.numeric = false,
    this.maxLines = 1,
    this.hint,
    this.suffix,
    this.readOnly = false,
    this.onChanged,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final bool required;
  final bool numeric;
  final int maxLines;
  final String? hint;
  final String? suffix;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 2),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF44506B),
                ),
              ),
              if (required)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.btnRed2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          onChanged: onChanged,
          textInputAction: textInputAction,
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
          inputFormatters: numeric
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))]
              : null,
          textAlign: numeric ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: numeric ? FontWeight.w700 : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            suffixStyle: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
            fillColor: readOnly ? const Color(0xFFF1F4F9) : Colors.white,
          ),
        ),
      ],
    );
  }
}

/// حقل عرض نتيجة محسوبة (غير قابل للتعديل) — للنتائج المحسوبة في الفاتورة.
class ResultTile extends StatelessWidget {
  const ResultTile({
    super.key,
    required this.label,
    required this.value,
    this.color = AppColors.navy,
    this.suffix,
  });

  final String label;
  final String value;
  final Color color;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1.1,
                  ),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    suffix!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// شريط بحث موحّد
class SearchBarField extends StatelessWidget {
  const SearchBarField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 20,
          color: AppColors.textMuted,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
