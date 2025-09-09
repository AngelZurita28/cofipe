import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/category_model.dart';
import '../../../../data/models/recurring_movement_model.dart';
import '../../../../data/repositories/movement_repository.dart';
import '../../../../data/repositories/user_repository.dart';

class RecurringMovementScreen extends ConsumerStatefulWidget {
  const RecurringMovementScreen({super.key, required this.category});
  final CategoryModel category;

  @override
  ConsumerState<RecurringMovementScreen> createState() =>
      _RecurringMovementScreenState();
}

class _RecurringMovementScreenState
    extends ConsumerState<RecurringMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  Frequency _frequency = Frequency.biweekly;
  DateTime? _nextDueDate;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    // Load existing data when the screen opens
    final recurringMovementAsync = ref.read(
      recurringMovementProvider(widget.category.id),
    );
    recurringMovementAsync.whenData((data) {
      if (data != null) {
        _amountController.text = data.amount.toString();
        _frequency = data.frequency;
        _nextDueDate = data.nextDueDate;
        _isActive = data.isActive;
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _nextDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _nextDueDate) {
      setState(() {
        _nextDueDate = pickedDate;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(userRepositoryProvider).currentUser;
    if (user == null) return;

    final recurringMovement = RecurringMovementModel(
      id: widget.category.id,
      userId: user.uid,
      categoryId: widget.category.id,
      amount: double.parse(_amountController.text),
      frequency: _frequency,
      nextDueDate: _nextDueDate ?? DateTime.now(),
      isActive: _isActive,
    );

    ref
        .read(movementRepositoryProvider)
        .setRecurringMovement(recurringMovement)
        .then((_) => context.pop())
        .catchError((e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingreso Recurrente'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Monto del Ingreso',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(prefixText: '\$ '),
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
            const SizedBox(height: 24),

            Text('Frecuencia', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<Frequency>(
              segments: const [
                ButtonSegment(value: Frequency.weekly, label: Text('Semanal')),
                ButtonSegment(
                  value: Frequency.biweekly,
                  label: Text('Quincenal'),
                ),
                ButtonSegment(value: Frequency.monthly, label: Text('Mensual')),
                ButtonSegment(value: Frequency.yearly, label: Text('Anual')),
              ],
              selected: {_frequency},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _frequency = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),

            Text(
              'Próximo Ingreso',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              title: Text(
                _nextDueDate == null
                    ? 'Seleccionar fecha'
                    : DateFormat(
                        'dd \'de\' MMMM, yyyy',
                        'es_MX',
                      ).format(_nextDueDate!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: 24),

            SwitchListTile(
              title: const Text('Activar ingreso recurrente'),
              value: _isActive,
              onChanged: (newValue) {
                setState(() {
                  _isActive = newValue;
                });
              },
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _save,
              child: const Text('Guardar Configuración'),
            ),
          ],
        ),
      ),
    );
  }
}
