import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/injection_container.dart' as di;
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/gym_class.dart';
import '../cubit/schedule_cubit.dart';
import '../cubit/schedule_state.dart';

class AddEditClassPage extends StatelessWidget {
  final GymClass? gymClass; // Jeśli null -> Tworzenie, Jeśli obiekt -> Edycja

  const AddEditClassPage({super.key, this.gymClass});

  @override
  Widget build(BuildContext context) {
    // Wstrzykujemy ScheduleCubit, żeby móc wysłać dane
    return BlocProvider(
      create: (context) => di.sl<ScheduleCubit>(),
      child: _AddEditClassView(gymClass: gymClass),
    );
  }
}

class _AddEditClassView extends StatefulWidget {
  final GymClass? gymClass;

  const _AddEditClassView({this.gymClass});

  @override
  State<_AddEditClassView> createState() => _AddEditClassViewState();
}

class _AddEditClassViewState extends State<_AddEditClassView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _capacityController;
  late TextEditingController _durationController;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool get isEditing => widget.gymClass != null;

  @override
  void initState() {
    super.initState();
    // Ustawiamy wartości początkowe (puste lub z edytowanego obiektu)
    _nameController = TextEditingController(text: widget.gymClass?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.gymClass?.description ?? '',
    );
    _capacityController = TextEditingController(
      text: widget.gymClass?.capacity.toString() ?? '15',
    );
    _durationController = TextEditingController(
      text: widget.gymClass?.durationMinutes.toString() ?? '60',
    );

    if (isEditing) {
      _selectedDate = widget.gymClass!.startTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.gymClass!.startTime);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  // Wybór Daty
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate:
          DateTime.now(), // Nie pozwalamy na daty z przeszłości przy tworzeniu
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Wybór Godziny
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    // Łączymy datę i godzinę w jeden obiekt DateTime
    final finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Pobieramy ID aktualnego użytkownika (Trenera)
    final authState = context.read<AuthCubit>().state;
    String trainerId = "unknown";
    if (authState is Authenticated) {
      trainerId = authState.user.id;
    }

    final newClass = GymClass(
      // Jeśli edytujemy, zachowaj stare ID. Jeśli tworzymy, wygeneruj nowe (używamy timestamp jako proste ID)
      id: isEditing
          ? widget.gymClass!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      trainerId: trainerId,
      startTime: finalDateTime,
      durationMinutes: int.parse(_durationController.text),
      capacity: int.parse(_capacityController.text),
      // Przy edycji zachowujemy listę zapisanych, przy nowym pusta lista
      registeredUserIds: isEditing ? widget.gymClass!.registeredUserIds : [],
    );

    if (isEditing) {
      context.read<ScheduleCubit>().updateClass(newClass);
    } else {
      context.read<ScheduleCubit>().addClass(newClass);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleCubit, ScheduleState>(
      listener: (context, state) {
        if (state is ScheduleOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(true); // Wracamy do poprzedniego ekranu i odświeżamy
        }
        if (state is ScheduleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? "Edytuj zajęcia" : "Nowe zajęcia"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Nazwa zajęć",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? "Podaj nazwę" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Opis",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          labelText: "Czas (min)",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? "Podaj czas" : null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        controller: _capacityController,
                        decoration: const InputDecoration(
                          labelText: "Miejsca",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? "Podaj ilość" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Sekcja Daty i Czasu
                ListTile(
                  title: const Text("Data"),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd').format(_selectedDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: const Text("Godzina"),
                  subtitle: Text(_selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: _pickTime,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isEditing ? "Zapisz zmiany" : "Utwórz zajęcia"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
