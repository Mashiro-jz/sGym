import 'package:agym/core/enums/user_role.dart';
import 'package:agym/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> register({
    required String email,
    required String password,
    required UserModel user,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<List<UserModel>> getAllUsers();
  Future<void> updateUserRole({required String uid, required UserRole newRole});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firebaseFirestore,
  });

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = userCredential.user!.uid;

    return _getUserFromFirestore(uid);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      return null;
    }
    return _getUserFromFirestore(currentUser.uid);
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required UserModel user,
  }) async {
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = userCredential.user!.uid;

    final newUser = user.copyWith(id: uid);

    await firebaseFirestore.collection('users').doc(uid).set(newUser.toJson());

    return newUser;
  }

  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc = await firebaseFirestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    } else {
      throw Exception('User not found in Firestore');
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await firebaseFirestore.collection('users').get();
    return snapshot.docs.map((doc) {
      return UserModel.fromJson(doc.data());
    }).toList();
  }

  @override
  Future<void> updateUserRole({
    required String uid,
    required UserRole newRole,
  }) async {
    // Zamieniamy np. UserRole.trainer na "trainer"
    String roleString = newRole.name;

    await firebaseFirestore.collection('users').doc(uid).update({
      'userRole': roleString,
    });
  }
}
