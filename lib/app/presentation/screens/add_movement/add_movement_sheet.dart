// lib/app/presentation/screens/add_movement/add_movement_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/category_model.dart';
import '../../../../data/models/movement_model.dart';
import '../../../../data/repositories/category_repository.dart'; // Importa el nuevo provider
import 'add_movement_notifier.dart';

class AddMovementSheet extends ConsumerStatefulWidget {
  const AddMovementSheet({super.key});

  @override
  ConsumerState<AddMovementSheet> createState() => _AddMovementSheetState();
}

class _AddMovementSheetState extends ConsumerState<AddMovementSheet> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  MovementType _selectedType = MovementType.expense;
  DateTime _selectedDate = DateTime.now();
  CategoryModel? _selectedCategory; // Ahora guardamos el objeto completo

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    // Validamos que se haya seleccionado una categoría
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una categoría'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ref
        .read(addMovementNotifierProvider.notifier)
        .saveMovement(
          description: _descriptionController.text,
          amount: amount,
          type: _selectedType,
          category:
              _selectedCategory!.name, // Pasamos el nombre de la categoría
          date: _selectedDate,
        );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el provider de categorías
    final categoriesAsyncValue = ref.watch(categoriesStreamProvider);
    // ... (resto del código del build) ...
    // ...
    // --- Dentro del `build` method ---

    // Escucha el estado del notifier para mostrar errores o loaders
    ref.listen<AddMovementState>(addMovementNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final state = ref.watch(addMovementNotifierProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Añadir Movimiento',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            SegmentedButton<MovementType>(
              segments: const [
                ButtonSegment(
                  value: MovementType.expense,
                  label: Text('Gasto'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: MovementType.income,
                  label: Text('Ingreso'),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _selectedType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Monto'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 16),

            // --- NUEVO DROPDOWN PARA CATEGORÍAS ---
            categoriesAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (categories) {
                // Aseguramos que _selectedCategory sea una instancia válida de la lista
                if (_selectedCategory == null && categories.isNotEmpty) {
                  _selectedCategory = categories.first;
                }

                return DropdownButtonFormField<CategoryModel>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (CategoryModel? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // ... (resto del código del submit button) ...
          ],
        ),
      ),
    );
  }
}
