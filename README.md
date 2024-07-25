# orange_card

A new Flutter project.

## Getting Started

  - Get info user: 
      mẫu lấy user trong đường dẫn <b>\orange_card\lib\ui\personalPage\components\profile.dart</b>

          import 'package:firebase_auth/firebase_auth.dart';
          final FirebaseAuth _auth = FirebaseAuth.instance;
            final user = _auth.currentUser;
          _displayName = user?.displayName ?? '';
          _preDisplayName = _displayName;
          _email = user?.email ?? '';
          _avatarUrl = '';

