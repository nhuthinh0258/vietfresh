import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Style2 extends StatelessWidget {
  const Style2({required this.outputText, super.key});

  final String outputText;

  @override
  Widget build(BuildContext context) {
    return Text(
      outputText,
      style: GoogleFonts.roboto(
        fontSize: 14,
        color: const Color.fromARGB(255, 1, 1, 1),
        fontWeight: FontWeight.normal
      ),
    );
  }
}
