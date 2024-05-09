import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Posture Progress
class PostureProgress extends ConsumerWidget {
  const PostureProgress({
    super.key,
    required this.progress,
    required this.description,
  });

  final double progress;
  final String description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Stack(
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              value: 1 / 100 * progress,
              color: Colors.orange,
              backgroundColor: const Color(
                0xFFE4E4E4,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: 10,
            bottom: 10,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(
                  0xFFE4E4E4,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
      title: Text(
        "${progress.toStringAsFixed(0)}%",
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      subtitle: Text(
        description,
        style: GoogleFonts.montserrat(
          color: Colors.grey,
        ),
      ),
    );
  }
}
