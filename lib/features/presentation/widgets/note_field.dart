import 'package:flutter/material.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class NoteField extends StatelessWidget {
  const NoteField({super.key});

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text('Add a note', style: context.t.titleLarge),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: 'Note',
            filled: true,
            fillColor: context.c.surfaceContainer,
            contentPadding: const EdgeInsets.all(12),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
        ),
      ],
    );
  }
}
