import 'package:chat_app/data/data_source/firebase_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../network/requests.dart';

abstract class AuthDataSource {
  Future<void> sendVerificationCode(
      {required String phoneNumber, required Function(String, int?) codeCent});

  Future<String?> signInWithCredential(UserAuthenticationRequest user);

  Future<bool> isUserAleardyExists(String userID);
}

class AuthDataSourceImpl implements AuthDataSource {

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthDataSourceImpl(this._auth , this._firestore);

  @override
  Future<String?> signInWithCredential(UserAuthenticationRequest user) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: user.verificationId, smsCode: user.smsCode);
    return (await _auth.signInWithCredential(credential)).user?.uid;
  }

  @override
  Future<void> sendVerificationCode(
      {required String phoneNumber,
      required Function(String, int?) codeCent}) async {
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (phoneAuthCredential) {},
        verificationFailed: (error) {},
        codeSent: codeCent,
        codeAutoRetrievalTimeout: (verificationId) {});
  }
  
  @override
  Future<bool> isUserAleardyExists(String userID) async {
    var doc = await _firestore.collection(USERS_COLLECTION_PATH).doc(userID).get();

    return doc.exists;
  }
}
