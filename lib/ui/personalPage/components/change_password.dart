import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orange_card/ui/message/sucess_message.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({Key? key}) : super(key: key);

  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  String _oldPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Change Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            obscureText: !_showOldPassword,
            decoration: InputDecoration(
              labelText: 'Old Password',
              filled: true,
              fillColor: Colors.white54,
              suffixIcon: IconButton(
                icon: Icon(
                    _showOldPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _showOldPassword = !_showOldPassword;
                  });
                },
              ),
            ),
            onChanged: (value) {
              _oldPassword = value;
            },
          ),
          SizedBox(height: 16),
          TextField(
            obscureText: !_showNewPassword,
            decoration: InputDecoration(
              labelText: 'New Password',
              filled: true,
              fillColor: Colors.white54,
              suffixIcon: IconButton(
                icon: Icon(
                    _showNewPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _showNewPassword = !_showNewPassword;
                  });
                },
              ),
            ),
            onChanged: (value) {
              _newPassword = value;
            },
          ),
          SizedBox(height: 16),
          TextField(
            obscureText: !_showConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              filled: true,
              fillColor: Colors.white54,
              suffixIcon: IconButton(
                icon: Icon(_showConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _showConfirmPassword = !_showConfirmPassword;
                  });
                },
              ),
            ),
            onChanged: (value) {
              _confirmPassword = value;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_newPassword != _confirmPassword) {
              MessageUtils.showFailureMessage(
                  context, 'New passwords do not match');
              return;
            }

            try {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                // Reauthenticate user before changing password
                AuthCredential credential = EmailAuthProvider.credential(
                    email: user.email!, password: _oldPassword);
                await user.reauthenticateWithCredential(credential);

                // Change password
                await user.updatePassword(_newPassword);
                MessageUtils.showSuccessMessage(
                    context, 'Password changed successfully');
                Navigator.of(context)
                    .pop(); // Close dialog after password change
              }
            } catch (e) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to change password: $e'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior
                      .floating, // Hiển thị SnackBar ở dạng floating
                ),
              );
            }
          },
          child: Text('Change Password'),
        ),
      ],
    );
  }
}
