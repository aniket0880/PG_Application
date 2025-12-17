import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:untitled/components/custom_buttons.dart';
import 'package:untitled/constants.dart';
import 'package:untitled/screens/home_screen/home_screen.dart';
import 'package:untitled/screens/login_screen/login_screen.dart';

class SignupScreen extends StatefulWidget {
  static String routeName = 'SignupScreen';

  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _passwordVisible = true;
  bool _confirmPasswordVisible = true;
  bool _acceptedTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 🔹 Generate PG Registration Number
  String _generateRegistrationNo() {
    final year = DateTime.now().year;
    final unique = DateTime.now().millisecondsSinceEpoch % 10000;
    return 'PG-$year-${unique.toString().padLeft(4, '0')}';
  }

  // 🔹 SIGN UP LOGIC
  Future<void> _signUp() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept Terms & Conditions')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) return;

      await user.updateDisplayName(_nameController.text.trim());

      final regNo = _generateRegistrationNo();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'userId': user.uid,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': user.email,
        'registrationNo': regNo,
        'joinedOn': FieldValue.serverTimestamp(),
        'role': 'client',
        'isActive': true,
      });

      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Signup failed';
      if (e.code == 'email-already-in-use') {
        msg = 'Email already registered';
      } else if (e.code == 'weak-password') {
        msg = 'Password too weak';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email address';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: 35.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text('Create an account',
                          style: Theme.of(context).textTheme.titleSmall),
                      sizedBox,
                    ],
                  ),
                  Image.asset(
                    'assets/images/img_1.png',
                    height: 20.h,
                    width: 40.w,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  color: kOtherColor,
                  borderRadius: kTopBorderRadius,
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        sizedBox,
                        _buildNameField(),
                        sizedBox,
                        _buildPhoneField(),
                        sizedBox,
                        _buildEmailField(),
                        sizedBox,
                        _buildPasswordField(),
                        sizedBox,
                        _buildConfirmPasswordField(),
                        sizedBox,
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptedTerms,
                              onChanged: (v) =>
                                  setState(() => _acceptedTerms = v ?? false),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                        () => _acceptedTerms = !_acceptedTerms),
                                child: Text(
                                  'I agree to the Terms & Conditions',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(fontSize: 10.sp),
                                ),
                              ),
                            ),
                          ],
                        ),
                        sizedBox,
                        _isLoading
                            ? const CircularProgressIndicator()
                            : DefaultButton(
                          onPress: _signUp,
                          title: 'SIGN UP',
                          iconData: Icons.arrow_forward_outlined,
                        ),
                        sizedBox,
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, LoginScreen.routeName),
                            child: Text(
                              'Already have an account? Sign in',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- FORM FIELDS ----------------

  TextFormField _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: kInputTextStyle,
      decoration: const InputDecoration(
        labelText: 'Full Name',
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (v) =>
      v == null || v.trim().length < 2 ? 'Enter valid name' : null,
    );
  }

  TextFormField _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: kInputTextStyle,
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Enter phone number';
        if (v.length != 10) return 'Enter valid 10-digit number';
        return null;
      },
    );
  }

  TextFormField _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: kInputTextStyle,
      decoration: const InputDecoration(
        labelText: 'Email',
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (v) =>
      v == null || !RegExp(emailPattern).hasMatch(v)
          ? 'Enter valid email'
          : null,
    );
  }

  TextFormField _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _passwordVisible,
      style: kInputTextStyle,
      decoration: InputDecoration(
        labelText: 'Password',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: IconButton(
          icon: Icon(_passwordVisible
              ? Icons.visibility_off
              : Icons.visibility),
          onPressed: () =>
              setState(() => _passwordVisible = !_passwordVisible),
        ),
      ),
      validator: (v) =>
      v == null || v.length < 6 ? 'Min 6 characters' : null,
    );
  }

  TextFormField _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _confirmPasswordVisible,
      style: kInputTextStyle,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: IconButton(
          icon: Icon(_confirmPasswordVisible
              ? Icons.visibility_off
              : Icons.visibility),
          onPressed: () => setState(
                  () => _confirmPasswordVisible = !_confirmPasswordVisible),
        ),
      ),
      validator: (v) =>
      v != _passwordController.text ? 'Passwords do not match' : null,
    );
  }
}
