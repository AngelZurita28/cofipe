import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/category_model.dart';
import '../../../../data/models/movement_model.dart';
import '../../../../data/repositories/category_repository.dart';
import 'add_movement_notifier.dart';

class AddMovementSheet extends ConsumerStatefulWidget {
  const AddMovementSheet({super.key});

  @override
  ConsumerState<AddMovementSheet> createState() => _AddMovementSheetState();
}

class _AddMovementSheetState extends ConsumerState<AddMovementSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  MovementType _selectedType = MovementType.expense;
  DateTime _selectedDateTime = DateTime.now();
  CategoryModel? _selectedCategory;

  // Solo una animación simple para la entrada
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Procesa y envía el formulario al notifier.
  void _submit() async {
    HapticFeedback.lightImpact();

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;

    final success = await ref
        .read(addMovementNotifierProvider.notifier)
        .saveMovement(
          description: _descriptionController.text.trim(),
          amount: amount,
          type: _selectedType,
          categoryId: _selectedCategory!.id,
          date: _selectedDateTime,
        );

    if (success && mounted) {
      HapticFeedback.heavyImpact();
      Navigator.of(context).pop();
    }
  }

  /// Selector de fecha
  Future<void> _selectDate() async {
    HapticFeedback.selectionClick();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  /// Selector de hora
  Future<void> _selectTime() async {
    HapticFeedback.selectionClick();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios de estado del notifier
    ref.listen<AddMovementState>(addMovementNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final state = ref.watch(addMovementNotifierProvider);
    final categoriesAsyncValue = ref.watch(categoriesStreamProvider);
    final isExpense = _selectedType == MovementType.expense;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Título
                Text(
                  'Añadir Movimiento',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Selector de tipo
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
                      _selectedCategory = null;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Campo de monto
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autofocus: true,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Monto',
                    prefixText: '\$ ',
                    filled: true,
                    fillColor: isExpense
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isExpense ? Colors.red : Colors.green,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Ingresa un monto';
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0)
                      return 'Ingresa un monto válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de descripción
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Ej: Almuerzo, Gasolina, Salario...',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingresa una descripción'
                      : null,
                ),
                const SizedBox(height: 16),

                // Selección de fecha y hora
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(_selectedDateTime),
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: _selectTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hora',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(_selectedDateTime),
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Selector de categorías
                categoriesAsyncValue.when(
                  loading: () => Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Error al cargar categorías: $err',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  data: (allCategories) {
                    final filteredCategories = allCategories
                        .where((cat) => cat.type == _selectedType)
                        .toList();

                    if (filteredCategories.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'No hay categorías para este tipo.\nCrea una categoría primero.',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return DropdownButtonFormField<CategoryModel>(
                      value: _selectedCategory,
                      hint: const Text('Seleccionar categoría'),
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      items: filteredCategories.map((category) {
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
                      validator: (value) =>
                          value == null ? 'Selecciona una categoría' : null,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Botón de guardar
                SizedBox(
                  height: 50,
                  child: state.isLoading
                      ? ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isExpense
                                ? Colors.red.shade600
                                : Colors.green.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Guardar ${isExpense ? 'Gasto' : 'Ingreso'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Hoy';
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return 'Ayer';
    } else {
      final months = [
        '',
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic',
      ];
      return '${date.day} ${months[date.month]}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
