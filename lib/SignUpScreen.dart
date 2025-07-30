import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ems/colors.dart';
import 'package:ems/LoginScreen.dart';
import 'package:ems/WelcomeScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Form Key and Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Firebase Authentication Function
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Create user with Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Save user data to Firestore
        try {
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          // Roll back user creation if Firestore fails
          await FirebaseAuth.instance.currentUser?.delete();
          setState(() {
            _errorMessage = 'Failed to save user data. Please try again.';
          });
          return;
        }

        // Navigate to home screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = _getAuthErrorMessage(e.code);
        });
        print('Firebase Auth Error: ${e.code}');
      } catch (e) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
        });
        print('Unexpected Error: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Helper function to map Firebase error codes to user-friendly messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account with that email already exists.';
      case 'invalid-email':
        return 'The email address format is invalid.';
      case 'operation-not-allowed':
        return 'Email/password sign-up is not enabled in your Firebase project.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return 'An error occurred during sign-up. Please try again.';
    }
  }

  // Reusable InputDecoration function for consistent styling
  InputDecoration _inputDecoration(String labelText, IconData prefixIcon) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: kGreyText),
      prefixIcon: Icon(prefixIcon, color: kGreyText),
      filled: true,
      fillColor: kTextFieldBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(fontSize: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBlue,
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: kDarkBlue,
        foregroundColor: kWhite,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: kWhite,
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/welcome');
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Create Your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: kAppNameColor,
                  ),
                ),
                const SizedBox(height: 32.0),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Full Name', Icons.person),
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: kWhite),
                  onChanged: (value) {
                    _formKey.currentState!.validate();
                  },
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration('Email Address', Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: kWhite),
                  onChanged: (value) {
                    _formKey.currentState!.validate();
                  },
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: _inputDecoration('Password', Icons.lock_outline),
                  obscureText: true,
                  style: TextStyle(color: kWhite),
                  onChanged: (value) {
                    _formKey.currentState!.validate();
                    if (_confirmPasswordController.text.isNotEmpty) {
                      _formKey.currentState!.validate();
                    }
                  },
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: _inputDecoration('Confirm Password', Icons.lock_reset),
                  obscureText: true,
                  style: TextStyle(color: kWhite),
                  onChanged: (value) {
                    _formKey.currentState!.validate();
                  },
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text.trim()) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32.0),

                // Sign Up Button
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator(color: kPrimaryBlue)),
                  )
                else
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBlue,
                      foregroundColor: kWhite,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),

                // Error Message Display
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[300], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 24.0),

                // Link to Login Screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: kGreyText),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: TextButton.styleFrom(foregroundColor: kGreyText),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}