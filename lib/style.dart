import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Style extends StatelessWidget {
  const Style({required this.outputText, super.key});

  final String outputText;

  @override
  Widget build(BuildContext context) {
    return Text(
      outputText,
      style: GoogleFonts.roboto(
        fontSize: 18,
        color: const Color.fromARGB(255, 1, 1, 1),
        fontWeight: FontWeight.bold
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      softWrap: true,
    );
  }
}
