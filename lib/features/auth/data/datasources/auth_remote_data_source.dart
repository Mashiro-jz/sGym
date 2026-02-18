import 'package:agym/core/enums/sex_role.dart';
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

  Future<void> updateUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    String? photoUrl,
    required SexRole sexRole,
  });

  Future<void> deleteUser({required String password});

  Future<List<UserModel>> getUsersDetails(List<String> uids);
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

  @override
  Future<void> updateUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    String? photoUrl,
    required SexRole sexRole,
  }) {
    return firebaseFirestore.collection('users').doc(uid).update({
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'photoUrl': photoUrl,
      'sexRole': sexRole.name,
    });
  }

  @override
  Future<void> deleteUser({required String password}) async {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      throw Exception("Użytkownik nie jest zalogowany");
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);

    await firebaseFirestore.collection('users').doc(user.uid).delete();

    await user.delete();
  }

  // TODO: PRZY ZMIANIE BAZY DANYCH, PAMIĘTAĆ O TYM LIMICIE
  @override
  Future<List<UserModel>> getUsersDetails(List<String> uids) async {
    // 1. Zabezpieczenie przed pustą listą
    if (uids.isEmpty) {
      return [];
    }

    // UWAGA: Firestore whereIn ma limit 10 elementów.
    // Jeśli przewidujesz grupy > 10 osób, trzeba to rozbić na paczki (chunks).
    // Poniżej proste rozwiązanie biorące pierwsze 10 osób (aby uniknąć crasha):
    final safeUids = uids.length > 10 ? uids.sublist(0, 10) : uids;

    try {
      final snapshot = await firebaseFirestore
          .collection('users')
          .where('id', whereIn: safeUids)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception("Błąd pobierania użytkowników: $e");
    }
  }
}
