
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_readrss/repository/firestore/collections.dart';
import 'package:flutter_readrss/use_case/auth/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  
  final firestore = FirebaseFirestore.instance;

  @override
  Future<void> deleteUser(String userId) async {
    await firestore.collection(usersCollection).doc(userId).delete(); 
  }
}