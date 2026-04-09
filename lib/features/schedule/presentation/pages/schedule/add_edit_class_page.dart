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

  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _bgColor = const Color(0xFF111812);
  final Color _surfaceColor = const Color(0xFF1E2B21);
  final Color _primaryColor = const Color(0xFF00E676);
  final Color _borderColor = const Color(0xFF2A3D2D);
  final Color _textHintColor = const Color(0xFF8B9D90);

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _primaryColor,
              onPrimary: Colors.black,
              surface: _surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: _primaryColor,
                onPrimary: Colors.black,
                surface: _surfaceColor,
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          ),
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
              content: Text(
                state.message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              backgroundColor: _primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          context.pop(true);
        }
        if (state is ScheduleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(
          title: Text(
            isEditing ? "Edytuj zajęcia" : "Zaplanuj zajęcia",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: _bgColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Informacje podstawowe"),
                const SizedBox(height: 12),
                _buildInputField(
                  label: "Nazwa zajęć",
                  controller: _nameController,
                  icon: Icons.fitness_center,
                  validator: (v) => v!.isEmpty ? "Podaj nazwę" : null,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: "Opis treningu",
                  controller: _descriptionController,
                  icon: Icons.description_outlined,
                  maxLines: 4,
                  minLines: 2,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: "Kategoria treningu",
                  controller: _categoryController,
                  icon: Icons.category_outlined,
                ),
                const SizedBox(height: 16),

                // Dropdown Poziomu
                DropdownButtonFormField<ClassLevel>(
                  initialValue: _classLevel,
                  dropdownColor: _surfaceColor,
                  icon: Icon(Icons.keyboard_arrow_down, color: _textHintColor),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Poziom zaawansowania",
                    hintStyle: TextStyle(color: _textHintColor, fontSize: 15),
                    prefixIcon: Icon(
                      Icons.leaderboard_outlined,
                      color: _textHintColor,
                      size: 22,
                    ),
                    filled: true,
                    fillColor: _surfaceColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: _borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: _borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: _primaryColor, width: 1.5),
                    ),
                  ),
                  onChanged: (ClassLevel? newValue) {
                    if (newValue != null) {
                      setState(() => _classLevel = newValue);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ClassLevel.beginner,
                      child: Text("Początkujący"),
                    ),
                    DropdownMenuItem(
                      value: ClassLevel.intermediate,
                      child: Text("Średnio zaawansowany"),
                    ),
                    DropdownMenuItem(
                      value: ClassLevel.advanced,
                      child: Text("Zaawansowany"),
                    ),
                    DropdownMenuItem(
                      value: ClassLevel.allLevels,
                      child: Text("Dla wszystkich"),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                _buildSectionTitle("Termin"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildPickerCard(
                        icon: Icons.calendar_today_outlined,
                        label: DateFormat('dd.MM.yyyy').format(_selectedDate),
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPickerCard(
                        icon: Icons.access_time,
                        label: _selectedTime.format(context),
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                _buildSectionTitle("Szczegóły logistyczne"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: "Czas (min)",
                        controller: _durationController,
                        icon: Icons.timer_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? "Wymagane" : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        label: "Limit osób",
                        controller: _capacityController,
                        icon: Icons.people_outline,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? "Wymagane" : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor: _primaryColor.withValues(alpha: 0.4),
                    ),
                    child: Text(
                      isEditing ? "Zapisz zmiany" : "Utwórz zajęcia",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: _textHintColor,
        letterSpacing: 0.5,
      ),
    );
  }

  // Ujednolicony input do formularza z ikoną w środku
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    int minLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      cursorColor: _primaryColor,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: _textHintColor, fontSize: 15),
        filled: true,
        fillColor: _surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        prefixIcon: Icon(icon, color: _textHintColor, size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPickerCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(
            alpha: 0.2,
          ), // Wklęsły efekt dla przycisku wyboru
          border: Border.all(color: _borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: _primaryColor, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
