import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:thirddraft/login.dart';



class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: EasySplashScreen(
          logoWidth: 150,
          loaderColor: Colors.white,
          logo: Image.asset('images/MetroBas.png'),
          backgroundColor: const Color.fromRGBO(8, 15, 44, 1),
          showLoader: true,
          loadingText: const Text(
            "Loading...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          navigator: const Login(),
          durationInSeconds: 2,
        ),
      ),
    );
  }
}
