import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirddraft/darkcubit/cubit.dart';
import 'package:thirddraft/darkcubit/states.dart';
// import 'Network/remote/dio_helper.dart';
import 'login.dart';

void main() async {
  // await DioHelperPayment.init();
     
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  runApp(MainApp(initialRoute: token != null ? '/PageOne' : '/login'));
  // runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  final String initialRoute;

  const MainApp({required this.initialRoute, super.key});
// const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) {
          return AppCubit();
        }),
      ],
      child: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {},
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // home: const TabScreens(),
            home: EasySplashScreen(
              logoWidth: 150,
              loaderColor: Colors.black,
              logo: Image.asset('images/MetroBas.png'),
              backgroundColor: Colors.white,
              showLoader: true,
              loadingText: const Text(
                "Loading...",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              navigator: initialRoute,
              durationInSeconds: 2,
            ),
            // initialRoute: initialRoute,
            routes: {
              '/login': (context) => const Login(),
              '/PageOne': (context) => const Login(),
            },
          );
        },
      ),
    );
  }
}
