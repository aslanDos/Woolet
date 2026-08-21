import 'package:flutter/material.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class NoteField extends StatelessWidget {
  const NoteField({super.key, this.controller});

  final TextEditingController? controller;

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
        const SizedBox(height: 18),
        TextField(
          controller: controller,
          autocorrect: false,
          style: context.t.bodyMedium,
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
