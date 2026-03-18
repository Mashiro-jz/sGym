import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/domain/enums/class_level.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/config/injection_container.dart' as di;
import '../../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../auth/presentation/cubit/auth_state.dart';

class AddEditClassPage extends StatelessWidget {
  final GymClass? gymClass;

  const AddEditClassPage({super.key, this.gymClass});

  @override
  Widget build(BuildContext context) {
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
  late TextEditingController _categoryController;
  ClassLevel _classLevel = ClassLevel.allLevels;

  // Domyślnie pokazujemy pełną godzinę przy tworzeniu zajęć
  DateTime _selectedDate = DateTime.now();
  DateTime now = DateTime.now();
  late DateTime roundedNextHour = DateTime(
    now.year,
    now.month,
    now.day,
    now.hour + 1,
    0,
    0,
    0,
    0,
  );
  late TimeOfDay _selectedTime = TimeOfDay.fromDateTime(roundedNextHour);

  bool get isEditing => widget.gymClass != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gymClass?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.gymClass?.description ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.gymClass?.category ?? '',
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
      _classLevel = widget.gymClass!.classLevel;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _capacityController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pl'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final authState = context.read<AuthCubit>().state;
    String trainerId = "unknown";
    if (authState is Authenticated) {
      trainerId = authState.user.id;
    }

    final newClass = GymClass(
      id: isEditing
          ? widget.gymClass!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      trainerId: trainerId,
      category: _categoryController.text,
      classLevel: _classLevel,
      startTime: finalDateTime,
      durationMinutes: int.parse(_durationController.text),
      capacity: int.parse(_capacityController.text),
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
          context.pop(true);
        }
        if (state is ScheduleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? "Edytuj zajęcia" : "Zaplanuj zajęcia"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Informacje podstawowe"),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(
                    "Nazwa zajęć",
                    Icons.fitness_center,
                  ),
                  validator: (v) => v!.isEmpty ? "Podaj nazwę" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _descriptionController,
                  decoration: _inputDecoration(
                    "Opis treningu",
                    Icons.description,
                  ),
                  maxLines: 4,
                  minLines: 2,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _categoryController,
                  decoration: _inputDecoration(
                    "Kategoria treningu",
                    Icons.category,
                  ),
                  maxLines: 1,
                  minLines: 1,
                ),
                const SizedBox(
                  height: 15,
                ), // Dodajemy odstęp od poprzedniego pola
                DropdownButtonFormField<ClassLevel>(
                  initialValue: _classLevel,
                  // Używamy Twojej własnej metody do stylizacji!
                  decoration: _inputDecoration(
                    "Poziom zaawansowania",
                    Icons.leaderboard, // Ikonka pasująca do poziomów
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.deepPurple,
                  ),
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Zaokrągla rogi rozwijanej listy
                  dropdownColor: Colors.white, // Czyste, białe tło dla menu
                  elevation: 4,
                  onChanged: (ClassLevel? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _classLevel = newValue;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ClassLevel.advanced,
                      child: Text("Zaawansowany"),
                    ),
                    DropdownMenuItem(
                      value: ClassLevel.intermediate,
                      child: Text("Średnio zaawansowany"),
                    ),
                    DropdownMenuItem(
                      value: ClassLevel.beginner,
                      child: Text("Początkujący"),
                    ),
                    DropdownMenuItem(
                      value: ClassLevel.allLevels,
                      child: Text("Dla wszystkich"),
                    ),
                  ],
                ),

                const SizedBox(height: 25),
                _buildSectionTitle("Termin"),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildPickerCard(
                        icon: Icons.calendar_today,
                        label: DateFormat('dd.MM.yyyy').format(_selectedDate),
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildPickerCard(
                        icon: Icons.access_time,
                        label: _selectedTime.format(context),
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),
                _buildSectionTitle("Szczegóły"),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        decoration: _inputDecoration("Czas (min)", Icons.timer),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? "Wymagane" : null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        controller: _capacityController,
                        decoration: _inputDecoration(
                          "Limit osób",
                          Icons.people,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? "Wymagane" : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isEditing ? "Zapisz zmiany" : "Utwórz zajęcia",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepPurple.shade300),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildPickerCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
