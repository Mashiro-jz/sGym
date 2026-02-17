import 'package:agym/features/schedule/data/models/gym_class_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<GymClassModel>> getSchedule(DateTime date);
  Future<void> createClass(GymClassModel gymClass);
  Future<void> updateClass(GymClassModel gymClass);
  Future<void> deleteClass(String classId);
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final FirebaseFirestore firebaseFirestore;

  ScheduleRemoteDataSourceImpl({required this.firebaseFirestore});

  @override
  Future<void> createClass(GymClassModel gymClass) async {
    await firebaseFirestore
        .collection('classes')
        .doc(gymClass.id)
        .set(gymClass.toJson());
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
        .update(gymClass.toJson());
  }
}
