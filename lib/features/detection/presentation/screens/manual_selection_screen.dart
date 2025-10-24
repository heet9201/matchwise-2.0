import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/domain_types.dart';
import '../../../../core/router/route_names.dart';

class ManualSelectionScreen extends StatelessWidget {
  const ManualSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final domains = [
      DomainType.job,
      DomainType.marriage,
      DomainType.product,
      DomainType.realEstate,
      DomainType.education,
      DomainType.custom,
    ];

    return Scaffold(
      backgroundColor: AppColors.neutralGray,
      appBar: AppBar(
        title: const Text('Choose Comparison Type'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: domains.length,
        itemBuilder: (context, index) {
          final domain = domains[index];
          return _buildDomainOption(context, domain);
        },
      ),
    );
  }

  Widget _buildDomainOption(BuildContext context, DomainType domain) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryGreenOverlay,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(domain.icon, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          domain.displayName,
          style: AppTypography.bodyMedium(color: AppColors.textPrimary)
              .copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          domain.description,
          style: AppTypography.small(color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          context.push(
            RouteNames.optionsUpload,
            extra: {'domainType': domain},
          );
        },
      ),
    );
  }
}
