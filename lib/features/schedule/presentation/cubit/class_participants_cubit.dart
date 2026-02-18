import 'package:agym/features/auth/domain/usecases/get_users_details.dart';
import 'package:agym/features/schedule/presentation/cubit/class_participants_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClassParticipantsCubit extends Cubit<ClassParticipantsState> {
  final GetUsersDetails getUsersDetails;

  ClassParticipantsCubit({required this.getUsersDetails})
    : super(ClassParticipantsInitial());

  Future<void> loadParticipants(List<String> participantIds) async {
    emit(ClassParticipantsLoading());
    try {
      final users = await getUsersDetails(participantIds);
      emit(ClassParticipantsLoaded(users));
    } catch (e) {
      emit(ClassParticipantsError("Nie udało się załadować uczestników: $e"));
    }
  }
}
