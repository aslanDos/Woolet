import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/features/presentation/widgets/form_tile.dart';

class NoteField extends StatelessWidget {
  const NoteField({super.key, this.controller});

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return FormTile(
      icon: LucideIcons.notebook_pen,
      label: 'Note',
      field: TextField(
        controller: controller,
        autocorrect: false,
        style: context.t.bodyMedium,
        textAlign: TextAlign.end,
        decoration: const InputDecoration(
          hintText: 'Add a note',
          isCollapsed: true,
          filled: false,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      ),
    );
  }
}
