import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Filler Button
class FillerButton extends ConsumerWidget {
  const FillerButton({
    super.key,
    required this.onPressed,
    this.number,
    this.label,
  });

  final VoidCallback onPressed;
  final int? number;
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialButton(
      color: Colors.white,
      padding: const EdgeInsets.all(1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 1,
      onPressed: () {},
      child: Wrap(
        spacing: 8,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(
            "${number ?? "1"}",
            style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 10),
          ),
          Text(
            label ?? "Label",
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Icon(
            Icons.play_circle,
            color: Colors.red,
            size: 15,
          ),
        ],
      ),
    );
  }
}
