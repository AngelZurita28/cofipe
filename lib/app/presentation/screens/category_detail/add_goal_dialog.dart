import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/goal_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/movement_model.dart';

class AddGoalDialog extends ConsumerStatefulWidget {
  const AddGoalDialog({super.key, required this.parentCategory});
  final CategoryModel parentCategory;

  @override
  ConsumerState<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends ConsumerState<AddGoalDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(userRepositoryProvider).currentUser;
    if (user == null) return;

    // Se crea el objeto de la nueva categoría-meta
    final goalCategory = CategoryModel(
      id: '',
      name: _nameController.text.trim(),
      type: MovementType.income, // Las metas siempre son de tipo ingreso
      iconAssetName: 'hogar.svg', // Ícono de 'savings'
      userId: user.uid,
      isGoal: true,
      parentCategoryId: widget.parentCategory.id,
    );

    final targetAmount = double.parse(_amountController.text);

    // Se llama al nuevo método del repositorio que crea ambos documentos
    ref
        .read(goalRepositoryProvider)
        .createGoalCategory(
          goalCategory: goalCategory,
          targetAmount: targetAmount,
        )
        .then((_) {
          Navigator.of(context).pop();
        })
        .catchError((e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Meta de Ahorro'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre (ej. Vacaciones)',
              ),
              autofocus: true,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Monto Objetivo (\$)',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Ingresa un monto';
                if (double.tryParse(value) == null || double.parse(value) <= 0)
                  return 'Ingresa un monto válido';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Guardar Meta')),
      ],
    );
  }
}
