import 'package:agym/features/schedule/domain/usecases/get_trainer_classes.dart';
import 'package:agym/features/schedule/presentation/cubit/trainer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrainerCubit extends Cubit<TrainerState> {
  final GetTrainerClasses getTrainerClasses;

  TrainerCubit({required this.getTrainerClasses}) : super(TrainerInitial());

  Future<void> loadTrainerClasses(String trainerId) async {
    emit(TrainerLoading());
    try {
      final classes = await getTrainerClasses(trainerId);
      emit(TrainerLoaded(classes));
    } catch (e) {
      emit(TrainerError("Nie udało się pobrać zajęć trenera: $e"));
    }
  }
}
