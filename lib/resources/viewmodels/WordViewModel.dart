import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orange_card/config/app_logger.dart';
import 'package:orange_card/resources/models/word.dart';
import 'package:orange_card/resources/repositories/wordRepository.dart';

class WordViewModel extends ChangeNotifier {
  final WordRepository _wordRepository = WordRepository();
  List<Word> _words = [];
  List<Word> get words => _words;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchWords(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      _words = await _wordRepository.getAllWords(id);
    } catch (e) {
      print('Error fetching words: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWord(Word word) async {
    try {
      await _wordRepository.addWord(word);
      _words.add(word);
      notifyListeners();
    } catch (e) {
      print('Error adding word: $e');
    }
  }

  Future<void> updateWord(Word updatedWord) async {
    try {
      await _wordRepository.updateWord(updatedWord);
      final index = _words.indexWhere((word) => word.id == updatedWord.id);
      if (index != -1) {
        _words[index] = updatedWord;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating word: $e');
    }
  }

  Future<void> deleteWord(String id) async {
    try {
      await _wordRepository.deleteWord(id);
      _words.removeWhere((word) => word.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting word: $e');
    }
  }

  Future<void> markWord(String topicId, Word word, bool marked) async {
    try {
      await _wordRepository.updateWordMark(topicId, word.id!, marked);

      notifyListeners();
    } catch (e) {
      print('Error deleting word: $e');
    }
  }

  bool checkMarked(List<String> userList) {
    return userList.contains(FirebaseAuth.instance.currentUser!.uid);
  }
}
