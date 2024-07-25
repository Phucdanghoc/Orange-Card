import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orange_card/resources/models/userInTopic.dart';
import 'package:orange_card/resources/models/word.dart';
import 'package:orange_card/resources/utils/enum.dart';
import '../models/topic.dart';

class TopicRepository {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _topicsCollection =
      FirebaseFirestore.instance.collection('topics');

  Future<String> addTopic(Topic topic, List<Word> words) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      DocumentReference topicRef = _topicsCollection.doc();
      String topicId = topicRef.id;
      batch.set(topicRef, topic.toMap());
      batch.update(topicRef, {
        'user': _usersCollection.doc(FirebaseAuth.instance.currentUser!.uid)
      });
      CollectionReference wordCollection = topicRef.collection('words');
      for (var word in words) {
        batch.set(wordCollection.doc(), word.toMap());
      }
      await batch.commit();
      return topicId;
    } catch (e) {
      print('Error adding topic: $e');
      throw e;
    }
  }

  Future<void> deleteTopic(String id) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      final topicRef = _topicsCollection.doc(id);
      final wordSnapshots = await topicRef.collection('words').get();

      for (final doc in wordSnapshots.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(topicRef);
      await batch.commit();
    } catch (e) {
      print('Error deleting topic: $e');
      throw e;
    }
  }

  Future<void> updateTopic(Topic topic, List<Word> words) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    try {
      final topicRef = _topicsCollection.doc(topic.id);
      batch.update(topicRef, topic.toMap());
      final wordCollection = topicRef.collection('words');
      final wordSnapshots = await wordCollection.get();
      for (final doc in wordSnapshots.docs) {
        batch.delete(doc.reference);
      }

      for (var word in words) {
        batch.set(wordCollection.doc(), word.toMap());
      }
      batch.update(topicRef, {'numberOfChildren': words.length});
      await batch.commit();
    } catch (e) {
      print('Error updating topic: $e');
      throw e;
    }
  }

  Future<List<Topic>> getAllTopicsByUserId(String userId,
      {int limit = 10, DocumentSnapshot? startAfter}) async {
    final userRef = FirebaseFirestore.instance.doc("/users/$userId");
    Query query =
        _topicsCollection.where("user", isEqualTo: userRef).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => _fromSnapshot(doc)).toList();
  }

  Future<Topic> getTopicByID(String id) async {
    final snapshot = await _topicsCollection.doc(id).get();
    final data = snapshot.data() as Map<String, dynamic>?;

    if (data != null) {
      return Topic.fromMap(data, id);
    } else {
      throw Exception("No data available for topic with ID $id");
    }
  }

  Future<List<UserInTopic>> getRank(String topicId) async {
    final snapshot =
        await _topicsCollection.doc(topicId).collection('ranks').get();
    return snapshot.docs
        .map((doc) => UserInTopic.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addRank(UserInTopic user, String topicId) async {
    await _topicsCollection.doc(topicId).collection('ranks').add(user.toMap());
  }

  Future<List<Topic>> getTopicsPublic() async {
    final snapshot = await _topicsCollection
        .where('status', isEqualTo: EnumToString.convertToString(STATUS.PUBLIC))
        .get();
    return snapshot.docs.map((doc) => _fromSnapshot(doc)).toList();
  }

  Future<List<Topic>> getTopicsSaved(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        return [];
      }

      final List<dynamic> topicIds = userDoc['topicIds'];
      final List<Topic> savedTopics = [];

      for (var topicId in topicIds) {
        final topicDoc = await _topicsCollection.doc(topicId).get();
        if (topicDoc.exists) {
          final topic = _fromSnapshot(topicDoc);
          if (topic.status == STATUS.PUBLIC) {
            savedTopics.add(topic);
          }
        }
      }

      return savedTopics;
    } catch (e) {
      print('Error fetching saved topics: $e');
      return [];
    }
  }

  Future<void> setStatusTopic(String status, String id) async {
    try {
      final topicRef = _topicsCollection.doc(id);
      await topicRef.update({'status': status});
    } catch (error) {
      print('Error setting status: $error');
      throw error;
    }
  }

  Topic _fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Topic(
      id: doc.id,
      title: data['title'],
      creationTime: data['creationTime'],
      numberOfChildren: data['numberOfChildren'],
      learnedWords: data['learnedWords'],
      status: EnumToString.fromString(STATUS.values, data['status']),
      updateTime: data['updateTime'],
      user: data['user'] as DocumentReference?,
      views: data['views'],
    );
  }
}
