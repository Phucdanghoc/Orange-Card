import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orange_card/config/app_logger.dart';
import 'package:orange_card/resources/models/folder.dart';
import 'package:orange_card/resources/models/topic.dart';
import 'package:orange_card/resources/repositories/folderRepository.dart';

class FolderViewModel extends ChangeNotifier {
  final FolderRepository _folderRepository = FolderRepository();
  List<Folder> _folders = [];
  List<Folder> get folders => _folders;
  List<Topic> _topics = [];
  List<Topic> get topics => _topics;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FolderViewModel() {
    loadFolders();
  }

  Future<void> loadFolders() async {
    try {
      _isLoading = true;
      notifyListeners();
      _folders = await _folderRepository
          .getFolders(FirebaseAuth.instance.currentUser!.uid);
    } catch (e) {
      print('Error loading folders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getTopicInModel(List<String> listTopicId) async {
    try {
      _isLoading = true;
      notifyListeners();
      _topics = await _folderRepository.getTopicInModel(listTopicId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFolder(String title) async {
    try {
      final folder = Folder(
        title: title,
        time: DateTime.now().millisecondsSinceEpoch,
        userId: FirebaseAuth.instance.currentUser!.uid,
        topicIds: [],
      );
      await _folderRepository.addFolder(folder);
      loadFolders();
    } catch (e) {
      print('Error adding folder: $e');
    }
  }

  Future<void> deleteFolder(Folder folder) async {
    try {
      await _folderRepository.deleteFolder(folder.id!);
      _folders.remove(folder);
      notifyListeners();
    } catch (e) {
      print('Error deleting folder: $e');
    }
  }

  Future<void> addTopicIdToFolder(String folderId, String topicId) async {
    try {
      await _folderRepository.addTopicId(folderId, topicId);
      await loadFolders();
      notifyListeners();
    } catch (e) {
      print('Error adding topic id to folder: $e');
    }
  }

  Future<void> removeTopicIdFromFolder(String folderId, String topicId) async {
    try {
      await _folderRepository.removeTopicId(folderId, topicId);
      await loadFolders();
      notifyListeners();
    } catch (e) {
      print('Error removing topic id from folder: $e');
    }
  }

  Future<void> removeTopicInFolder(Topic topic) async {
    try {
      await _folderRepository.removeTopicInFolder(
          topic.id!, FirebaseAuth.instance.currentUser!.uid);
      _topics.remove(topic);
      notifyListeners();
    } catch (e) {
      print('Error removing topic id from folder: $e');
    }
  }

  bool checkInFolder(String folderId, String topicId) {
    logger.f(_folders[0].topicIds.length);
    Folder folder = _folders.firstWhere((folder) => folder.id == folderId);
    return folder.topicIds.contains(topicId);
  }

  Future<void> searchFolder(String query) async {
    if (query.isEmpty) {
      await loadFolders();
    }
    _folders = _folders.where((folder) {
      return folder.title.toLowerCase().contains(query.toLowerCase());
    }).toList();
    notifyListeners();
  }

  Folder getFolderById(List<Folder> folders, String folderId) {
    return folders.firstWhere((folder) => folder.id == folderId);
  }
}
