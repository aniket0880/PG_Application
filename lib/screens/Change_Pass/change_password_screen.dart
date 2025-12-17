import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:untitled/constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String routeName = 'ChangePasswordScreen';

  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ================= CHANGE PASSWORD LOGIC =================
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'User not logged in',
        );
      }

      // ---------- RE-AUTHENTICATE ----------
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      // ---------- UPDATE PASSWORD ----------
      await user.updatePassword(_newPasswordController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );

      Navigator.pop(context); // go back
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to change password';

      if (e.code == 'wrong-password') {
        message = 'Current password is incorrect';
      } else if (e.code == 'weak-password') {
        message = 'New password is too weak (min 6 chars)';
      } else if (e.code == 'requires-recent-login') {
        message = 'Please login again and retry';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Container(
        padding: EdgeInsets.all(kDefaultPadding),
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: kTopBorderRadius,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(
                controller: _currentPasswordController,
                label: 'Current Password',
              ),
              SizedBox(height: 2.h),

              _buildField(
                controller: _newPasswordController,
                label: 'New Password',
              ),
              SizedBox(height: 2.h),

              _buildField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                isConfirm: true,
              ),
              SizedBox(height: 4.h),

              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Update Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= INPUT FIELD =================
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    bool isConfirm = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() => _obscure = !_obscure);
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (!isConfirm && value.length < 6) return 'Minimum 6 characters';
        if (isConfirm && value != _newPasswordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
