import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';

class CategoriesSheet extends StatelessWidget {
  const CategoriesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      actions: [
        IconButton.filled(onPressed: () {}, icon: Icon(LucideIcons.plus)),
      ],
      title: Text('Categories'),
      child: _CategoriesForm(),
    );
  }
}

class _CategoriesForm extends StatefulWidget {
  const _CategoriesForm();

  @override
  State<_CategoriesForm> createState() => __CategoriesFormState();
}

class __CategoriesFormState extends State<_CategoriesForm> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(mainAxisSize: .min, children: [Text('Categories Form')]),
    );
  }
}
