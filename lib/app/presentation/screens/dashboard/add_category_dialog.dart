// // lib/app/presentation/screens/dashboard/add_category_dialog.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cofipe/data/models/category_model.dart';
// import 'package:cofipe/data/models/movement_model.dart';
// import 'package:cofipe/data/repositories/category_repository.dart';
// import 'package:cofipe/data/repositories/user_repository.dart';

// class AddCategoryDialog extends ConsumerStatefulWidget {
//   const AddCategoryDialog({super.key});

//   @override
//   ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
// }

// class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
//   final _nameController = TextEditingController();
//   MovementType _selectedType = MovementType.expense;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }

//   void _submit() {
//     final name = _nameController.text.trim();
//     if (name.isEmpty) {
//       // Simple validation
//       return;
//     }

//     final user = ref.read(userRepositoryProvider).currentUser;
//     if (user == null) return; // Should not happen if we are on this screen

//     final newCategory = CategoryModel(
//       id: '', // Firestore will generate it
//       name: name,
//       type: _selectedType,
//       userId: user.uid, // Assign it to the current user
//     );

//     // Call the repository to add the new category
//     ref
//         .read(categoryRepositoryProvider)
//         .addCategory(newCategory)
//         .then((_) {
//           Navigator.of(context).pop(); // Close the dialog on success
//         })
//         .catchError((error) {
//           // Show an error message if something goes wrong
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error: ${error.toString()}'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Nueva Categoría'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: _nameController,
//             decoration: const InputDecoration(
//               labelText: 'Nombre de la categoría',
//             ),
//             autofocus: true,
//           ),
//           const SizedBox(height: 24),
//           SegmentedButton<MovementType>(
//             segments: const [
//               ButtonSegment(value: MovementType.expense, label: Text('Gasto')),
//               ButtonSegment(value: MovementType.income, label: Text('Ingreso')),
//             ],
//             selected: {_selectedType},
//             onSelectionChanged: (newSelection) {
//               setState(() {
//                 _selectedType = newSelection.first;
//               });
//             },
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancelar'),
//         ),
//         ElevatedButton(onPressed: _submit, child: const Text('Guardar')),
//       ],
//     );
//   }
// }
