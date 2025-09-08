// lib/app/presentation/screens/category_detail/add_goal_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/goal_model.dart';
import '../../../../data/repositories/goal_repository.dart';
import '../../../../data/repositories/user_repository.dart';

class AddGoalDialog extends ConsumerStatefulWidget {
  const AddGoalDialog({super.key, required this.categoryId});
  final String categoryId;

  @override
  ConsumerState<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends ConsumerState<AddGoalDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = ref.read(userRepositoryProvider).currentUser;
    if (user == null) return;

    final newGoal = GoalModel(
      id: '', // Firestore will generate it
      name: _nameController.text.trim(),
      targetAmount: double.parse(_amountController.text),
      categoryId: widget.categoryId,
      userId: user.uid,
    );

    ref
        .read(goalRepositoryProvider)
        .addGoal(newGoal)
        .then((_) {
          Navigator.of(context).pop();
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
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
