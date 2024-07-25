import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orange_card/config/app_logger.dart';
import 'package:orange_card/resources/models/user.dart';
import 'package:orange_card/resources/repositories/userRepository.dart';
import 'package:orange_card/resources/viewmodels/TopicViewmodel.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository userRepository = UserRepository();
  TopicViewModel topicViewModel = TopicViewModel();
  UserCurrent? _userCurrent;
  UserCurrent? get userCurrent => _userCurrent;

  UserViewModel() {}

  Future<UserCurrent?> getUserByDocumentReference(
      DocumentReference? userRef) async {
    return await userRepository.getUserByDocumentReference(userRef);
  }

  bool checkCurrentUser(DocumentReference<Object?>? user) {
    return userRepository.checkCurrentUser(user);
  }

  Future<void> getUserById() async {
    logger.e(FirebaseAuth.instance.currentUser!.email);
    User currentUser = FirebaseAuth.instance.currentUser!;
    if (currentUser != null) {
      _userCurrent = await userRepository.getUserById(currentUser.uid);
      notifyListeners();
    } else {
      throw Exception('No authenticated user found');
    }
    notifyListeners();
  }

  Future<void> addTopicId(String topicId) async {
    try {
      await userRepository.addTopicId(
          FirebaseAuth.instance.currentUser!.uid, topicId);
      topicViewModel.loadTopicsSaved();
      _userCurrent!.topicIds!.add(topicId);
      notifyListeners();
    } catch (e) {
      print('Error adding topic id: $e');
    }
  }

  Future<void> removeTopicId(String topicId) async {
    try {
      await userRepository.removeTopicId(
          FirebaseAuth.instance.currentUser!.uid, topicId);
      topicViewModel.loadTopicsSaved();
      _userCurrent!.topicIds!.remove(topicId);

      notifyListeners();
    } catch (e) {
      print('Error removing topic id: $e');
    }
  }
}
