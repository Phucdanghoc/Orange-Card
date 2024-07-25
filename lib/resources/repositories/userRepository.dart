import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:orange_card/config/app_logger.dart';
import 'package:orange_card/resources/models/user.dart';

class UserRepository {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CollectionReference<Map<String, dynamic>>> getTopicUser(
      String userId) async {
    return _usersCollection.doc(userId).collection("topics");
  }

  Future<void> create(
      String username, String avatar, List<String> topicIds) async {
    User? firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      String uid = firebaseUser.uid;
      DocumentSnapshot userDoc = await _usersCollection.doc(uid).get();
      if (userDoc.exists) {
        print('User already exists');
      } else {
        UserCurrent userCurrent = UserCurrent(
          username: username,
          avatar: avatar,
          topicIds: topicIds,
          quiz_gold: 0,
          quiz_point: 0,
          typing_gold: 0,
          typing_point: 0,
        );
        await _usersCollection.doc(uid).set(userCurrent.toMap());
      }
    } else {
      throw Exception('User is not authenticated');
    }
  }

  Future<UserCurrent> getUserById(String userId) async {
    final snapshot = await _usersCollection.doc(userId).get();
    final Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    if (data != null) {
      final user = UserCurrent.fromMap(data);
      return user;
    } else {
      throw Exception("No data available for topic with ID $userId");
    }
  }

  Future<List<UserCurrent>> getAllUsers() async {
    final querySnapshot = await _usersCollection.get();
    final users = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return UserCurrent.fromMap(data);
    }).toList();
    return users;
  }

  Future<List<UserCurrent>> getRankedUsers() async {
    List<UserCurrent> users = await getAllUsers();
    List<UserCurrent> modifiedUsers = [];

    // Tạo một bản sao của mỗi người dùng và cập nhật giá trị quiz_point và typing_point
    for (var user in users) {
      UserCurrent modifiedUser = UserCurrent(
        // Copy các thuộc tính từ user
        username: user.username,
        avatar: user.avatar,
        topicIds: user.topicIds,
        // Cập nhật giá trị quiz_point và typing_point, nếu null thì đặt thành 0
        quiz_point: user.quiz_point ?? 0,
        typing_point: user.typing_point ?? 0,
      );
      modifiedUsers.add(modifiedUser);
    }

    modifiedUsers.sort((a, b) {
      // Tính tổng điểm của mỗi người dùng
      int aTotalPoints = a.quiz_point! + a.typing_point!;
      int bTotalPoints = b.quiz_point! + b.typing_point!;
      return bTotalPoints.compareTo(aTotalPoints);
    });
    return modifiedUsers;
  }

  Future<Map<String, int>> getAchievementUsersById(String userId) async {
    UserCurrent users = await getUserById(userId);
    Map<String, int> res = {
      "point": (users.quiz_point ?? 0) + (users.typing_point ?? 0),
      "gold": (users.quiz_gold ?? 0) + (users.typing_gold ?? 0)
    };
    return res;
  }

  Future<void> updateAvatar(String userId, String newAvatar) async {
    await _usersCollection.doc(userId).update({
      'avatarUrl': newAvatar,
    });
  }

  Future<void> updateTopicIds(String userId, List<String> newTopicIds) async {
    await _usersCollection.doc(userId).update({
      'topicIds': newTopicIds,
    });
  }

  Future<UserCurrent?> userFromDocumentReference(
      DocumentReference<Map<String, dynamic>>? userRef) async {
    try {
      if (userRef == null) {
        throw Exception('User reference is null');
      }

      DocumentSnapshot<Map<String, dynamic>> snapshot = await userRef.get();
      print(snapshot.data());

      if (snapshot.exists) {
        return _fromSnapshot(snapshot);
      } else {
        print('User document does not exist');
        return null; // Return null when user document doesn't exist
      }
    } catch (e) {
      print("Error creating UserCurrent from DocumentReference: $e");
      return null; // Return null in case of any errors
    }
  }

  Future<String?> getAvatar(DocumentReference<Object?>? userRef) async {
    try {
      if (userRef == null) {
        return null;
      }

      final snapshot = await userRef.get();
      final Map<String, dynamic>? data =
          snapshot.data() as Map<String, dynamic>?;

      if (snapshot.exists) {
        return data?['avatarUrl'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting user avatar: $e");
      return null; // Error occurred
    }
  }

  bool checkCurrentUser(DocumentReference<Object?>? user) {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      DocumentReference currentUserRef =
          _firestore.collection('users').doc(firebaseUser.uid);
      return user == currentUserRef;
    } else {
      return false;
    }
  }

  Future<UserCurrent?> getUserByDocumentReference(
      DocumentReference? userRef) async {
    if (userRef == null) {
      return null;
    }

    try {
      DocumentSnapshot<Object?> snapshot = await userRef.get();
      if (snapshot.exists) {
        logger.e(snapshot.data());
        return UserCurrent.fromMap(snapshot.data()! as Map<String, dynamic>);
      } else {
        print('User document does not exist');
        return null; // Return null when user document doesn't exist
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null; // Return null in case of any errors
    }
  }

  UserCurrent _fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserCurrent(
        username: data['displayName'],
        avatar: data['avatarUrl'],
        topicIds: List<String>.from(data['topicIds']));
  }

  Future<String> getImageAddress(String imagePath) async {
    try {
      Reference imageRef = FirebaseStorage.instance.ref().child(imagePath);
      String address =
          await imageRef.getMetadata().then((value) => value.fullPath);
      return address;
    } catch (e) {
      print('Error getting image address: $e');
      return ''; // Return an empty string or null to signify failure
    }
  }

  Future<void> addTopicId(String userId, String topicId) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.update(
        _usersCollection.doc(userId),
        {
          'topicIds': FieldValue.arrayUnion([topicId])
        },
      );
      await batch.commit();
    } catch (e) {
      print('Error adding topic id: $e');
      throw e; // Rethrow the caught exception
    }
  }

  Future<void> removeTopicId(String userId, String topicId) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.update(
        _usersCollection.doc(userId),
        {
          'topicIds': FieldValue.arrayRemove([topicId])
        },
      );
      await batch.commit();
    } catch (e) {
      print('Error removing topic id: $e');
      throw e; // Rethrow the caught exception
    }
  }
}
