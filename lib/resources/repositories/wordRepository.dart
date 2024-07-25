import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orange_card/resources/models/word.dart';

class WordRepository {
  final CollectionReference _wordsCollection =
      FirebaseFirestore.instance.collection('words');
  final CollectionReference _topicsCollection =
      FirebaseFirestore.instance.collection('topics');
      
  Future<List<Word>> getAllWords(String topicId) async {
    List<Word> words = [];
    CollectionReference wordCollection =
        FirebaseFirestore.instance.collection("topics");
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await wordCollection.doc(topicId).collection('words').get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc
        in querySnapshot.docs) {
      Word word = Word.fromMap(doc.data(), doc.id);
      words.add(word);
    }
    return words;
  }

  Future<void> updateWordMark(
      String topicId, String wordId, bool marked) async {
    DocumentReference wordRef =
        _topicsCollection.doc(topicId).collection('words').doc(wordId);
    try {
      if (marked) {
        await wordRef.update({
          'userMarked': FieldValue.arrayUnion([
            FirebaseAuth.instance.currentUser!.uid
          ]), // Add id to userMarked list
        });
      } else {
        await wordRef.update({
          'userMarked': FieldValue.arrayRemove([
            FirebaseAuth.instance.currentUser!.uid
          ]), // Remove id from userMarked list
        });
      }

      print('Word mark updated successfully.');
    } catch (e) {
      print('Error updating word mark: $e');
    }
  }

  Future<void> addWord(Word word) async {
    await _wordsCollection.add(word.toMap());
  }

  Future<void> updateWord(Word word) async {
    await _wordsCollection.doc(word.id).update(word.toMap());
  }

  Future<void> deleteWord(String id) async {
    await _wordsCollection.doc(id).delete();
  }

  Word _fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Word(
      id: doc.id,
      english: data['english'],
      vietnamese: data['vietnamese'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      imageUrl: data['imageUrl'],
      learnt: data['learnt'],
      marked: data['markedUser'],
      userMarked: List<String>.from(data['userMarked']),
    );
  }
}
