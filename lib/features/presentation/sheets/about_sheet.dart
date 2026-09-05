import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:woolet/core/extensions/localization_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/features/presentation/widgets/custom_bottom_sheet.dart';

class AboutSheet extends StatelessWidget {
  const AboutSheet({super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder<PackageInfo>(
    future: PackageInfo.fromPlatform(),
    builder: (context, snapshot) => CustomBottomSheet(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.aboutApp, style: context.t.headlineMedium),
          const SizedBox(height: 20),
          Text('Woolet', style: context.t.titleLarge),
          const SizedBox(height: 8),
          Text(
            '${context.l10n.version} ${snapshot.data?.version ?? '—'} '
            '(${snapshot.data?.buildNumber ?? '—'})',
            style: context.t.bodyMedium?.copyWith(
              color: context.c.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}
