import 'package:sgym/features/schedule/domain/usecases/get_trainer_classes.dart';
import 'package:sgym/features/schedule/presentation/cubit/trainer_state.dart';
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
      emit(TrainerError("Nie udaĹ‚o siÄ™ pobraÄ‡ zajÄ™Ä‡ trenera: $e"));
    }
  }
}
