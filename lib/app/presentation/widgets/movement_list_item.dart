// lib/app/presentation/widgets/movement_list_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/movement_model.dart';

class MovementListItem extends StatelessWidget {
  const MovementListItem({
    super.key,
    required this.movement,
    required this.category,
  });

  final MovementModel movement;
  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final isIncome = movement.type == MovementType.income;
    final Color amountColor = isIncome
        ? Colors.green.shade600
        : Colors.red.shade600;
    final String iconAsset = isIncome
        ? 'assets/icons/arrow-trending-up.svg'
        : 'assets/icons/arrow-trending-down.svg';
    final String formattedDate = DateFormat(
      "dd 'de' MMMM 'del' yyyy",
      'es_MX',
    ).format(movement.date);

    return ListTile(
      leading: SvgPicture.asset(
        iconAsset,
        height: 40,
        width: 40,
        colorFilter: ColorFilter.mode(amountColor, BlendMode.srcIn),
      ),
      title: Text(
        movement.description,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(category.name),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\$${movement.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedDate,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
