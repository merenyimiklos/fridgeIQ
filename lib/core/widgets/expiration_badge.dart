import 'package:flutter/material.dart';
import 'package:fridgeiq/core/utils/date_utils.dart';

class ExpirationBadge extends StatelessWidget {
  const ExpirationBadge({
    super.key,
    required this.expirationDate,
    this.warningDays = 3,
  });

  final DateTime expirationDate;
  final int warningDays;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isExpired = AppDateUtils.isExpired(expirationDate);
    final isExpiringSoon = AppDateUtils.isExpiringSoon(
      expirationDate,
      warningDays: warningDays,
    );

    final Color backgroundColor;
    final Color textColor;

    if (isExpired) {
      backgroundColor = colorScheme.error;
      textColor = colorScheme.onError;
    } else if (isExpiringSoon) {
      backgroundColor = Colors.orange;
      textColor = Colors.white;
    } else {
      backgroundColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        AppDateUtils.expirationLabel(expirationDate),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
