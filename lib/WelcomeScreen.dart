import 'package:flutter/material.dart';
import '../colors.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kWhite, // Using the constant from our colors file
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _LogoSection(),
          ),
          Expanded(
            flex: 2,
            child: _ButtonSection(),
          ),
        ],
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhite,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100.0),
            Image(
              image: AssetImage('assets/images/emslogo.png'),
              height: 300.0,
            ),
          ],
        ),
      ),
    );
  }
}

class _ButtonSection extends StatelessWidget {
  const _ButtonSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kDarkBlue, // Using the constant
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50.0),
          topRight: Radius.circular(50.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue, // Using the constant
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 18, color: kWhite),
              ),
            ),
            const SizedBox(height: 20.0),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: kWhite,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                side: const BorderSide(color: kPrimaryBlue, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}