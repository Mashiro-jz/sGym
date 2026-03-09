import 'package:agym/features/schedule/data/models/gym_class_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<GymClassModel>> getSchedule(DateTime date);
  Future<void> createClass(GymClassModel gymClass);
  Future<void> updateClass(GymClassModel gymClass);
  Future<void> deleteClass(String classId);
  Future<void> signUpForClass(String classId, String userId);
  Future<void> signOutFromClass(String classId, String userId);
  Future<List<GymClassModel>> getUserSchedule(String userId);
  Future<List<GymClassModel>> getTrainerClasses(String trainerId);
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final FirebaseFirestore firebaseFirestore;

  ScheduleRemoteDataSourceImpl({required this.firebaseFirestore});

  @override
  Future<void> createClass(GymClassModel gymClass) async {
    await firebaseFirestore
        .collection('classes')
        .doc(gymClass.id)
        .set(gymClass.toFirestore());
  }

  @override
  Future<void> deleteClass(String classId) async {
    await firebaseFirestore.collection('classes').doc(classId).delete();
  }

  @override
  Future<List<GymClassModel>> getSchedule(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    QuerySnapshot snapshot = await firebaseFirestore
        .collection('classes')
        .where('startTime', isGreaterThanOrEqualTo: startOfDay)
        .where('startTime', isLessThan: endOfDay)
        .get();
    return snapshot.docs
        .map(
          (doc) => GymClassModel.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> updateClass(GymClassModel gymClass) async {
    await firebaseFirestore
        .collection('classes')
        .doc(gymClass.id)
        .update(gymClass.toFirestore());
  }

  @override
  Future<void> signUpForClass(String classId, String userId) async {
    await firebaseFirestore.collection('classes').doc(classId).update({
      'registeredUserIds': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> signOutFromClass(String classId, String userId) async {
    await firebaseFirestore.collection('classes').doc(classId).update({
      'registeredUserIds': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<List<GymClassModel>> getUserSchedule(String userId) async {
    final snapshot = await firebaseFirestore
        .collection('classes')
        .where('registeredUserIds', arrayContains: userId)
        .get();

    final classes = snapshot.docs
        .map((doc) => GymClassModel.fromJson(doc.data()))
        .toList();

    classes.sort((a, b) => a.startTime.compareTo(b.startTime));

    return classes;
  }

  @override
  Future<List<GymClassModel>> getTrainerClasses(String trainerId) async {
    final snapshot = await firebaseFirestore
        .collection('classes')
        .where('trainerId', isEqualTo: trainerId)
        .where('startTime', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('startTime', descending: false)
        .get();
    final classes = snapshot.docs
        .map((doc) => GymClassModel.fromJson(doc.data()))
        .toList();

    return classes;
  }
}
