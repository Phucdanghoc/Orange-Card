import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orange_card/resources/models/topicRank.dart';
import 'package:orange_card/resources/models/user.dart';
import 'package:orange_card/resources/repositories/userRepository.dart';

import '../../../../core/exception.dart';

abstract class TypingGameRemoteDataSource {
  Future<void> updateUserPoint(
      String uid, Map<String, dynamic> map, String topicId, int point);
  Future<void> updateUserGold(String uid, Map<String, dynamic> map);
}

class TypingGameRemoteDataSourceImpl implements TypingGameRemoteDataSource {
  final FirebaseFirestore _db;
  final String _users = "users";
  final String _topicRanks = "topicRanks";
  UserRepository _userRepository = new UserRepository();

  TypingGameRemoteDataSourceImpl(this._db);

  @override
  Future<void> updateUserPoint(
      String uid, Map<String, dynamic> map, String topicId, int point) async {
    try {
      await _db.collection(_users).doc(uid).update(map);

      // Lấy thông tin người dùng hiện tại
      UserCurrent userCurrent = await _userRepository.getUserById(uid);
      // Lấy tài liệu topicRank theo topicId
      DocumentReference topicDocRef = _db.collection(_topicRanks).doc(topicId);
      DocumentSnapshot topicDocSnapshot = await topicDocRef.get();

      if (topicDocSnapshot.exists) {
        // Nếu tài liệu topicRank đã tồn tại, cập nhật hoặc thêm mới người dùng
        TopicRank topicRank =
            TopicRank.fromMap(topicDocSnapshot.data() as Map<String, dynamic>);
        List<Map<String, dynamic>> users = topicRank.users ?? [];

        // Kiểm tra xem uid đã tồn tại trong danh sách users chưa
        bool userExists = false;
        for (var user in users) {
          if (user['userId'] == uid) {
            if ((user['maxPoint'] ?? 0) < point) {
              user['maxPoint'] = point;
              user['avatar'] = userCurrent.avatar;
              user['username'] = userCurrent.username;
              users.sort(
                  (a, b) => (a['maxPoint'] ?? 0).compareTo(b['maxPoint'] ?? 0));
            }
            userExists = true;
            break;
          }
        }

        // Nếu uid chưa tồn tại trong danh sách users, thêm mới người dùng
        if (!userExists) {
          if (users.length < 3) {
            users.add({
              'userId': uid,
              'maxPoint': point,
              'avatar': userCurrent.avatar,
              'username': userCurrent.username,
            });
            users.sort(
                (a, b) => (a['maxPoint'] ?? 0).compareTo(b['maxPoint'] ?? 0));
          } else {
            // Nếu có đủ 3 người dùng, tìm người dùng có điểm thấp nhất
            users.sort(
                (a, b) => (a['maxPoint'] ?? 0).compareTo(b['maxPoint'] ?? 0));
            if ((users[0]['maxPoint'] ?? 0) < point) {
              users[0] = {
                'userId': uid,
                'maxPoint': point,
                'avatar': userCurrent.avatar,
                'username': userCurrent.username,
              };
            }
          }
        }

        // Cập nhật tài liệu topicRank
        await topicDocRef.update({
          'users': users,
        });
      } else {
        // Nếu tài liệu topicRank chưa tồn tại, tạo mới với người dùng đầu tiên
        await topicDocRef.set({
          'users': [
            {
              'userId': uid,
              'maxPoint': point,
              'avatar': userCurrent.avatar,
              'username': userCurrent.username,
            },
          ],
        });
      }
    } on FirebaseException {
      rethrow;
    } on UnimplementedError catch (e) {
      throw DatabaseException(e.message ?? '');
    }
  }

  @override
  Future<void> updateUserGold(String uid, Map<String, dynamic> map) async {
    try {
      await _db.collection(_users).doc(uid).update(map);
    } on FirebaseException {
      rethrow;
    } on UnimplementedError catch (e) {
      throw DatabaseException(e.message ?? '');
    }
  }
}
