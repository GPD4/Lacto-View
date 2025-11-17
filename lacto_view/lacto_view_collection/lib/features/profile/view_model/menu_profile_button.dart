import 'package:flutter/material.dart';

class ArrowMenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ArrowMenuButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF7FCFB),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        elevation: 0,
        side: const BorderSide(
          color: Color.fromARGB(255, 63, 63, 63), // Cor da borda
          width: 1.0, // Espessura da borda
        ),
      ),
      onPressed: onPressed,
      child: Row(
        children: [Text(text), const Spacer(), const Icon(Icons.arrow_forward)],
      ),
    );
  }
}
