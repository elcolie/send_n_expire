import 'package:flutter/material.dart';
import 'package:frontend/screens/enter_password.dart';
import 'package:frontend/screens/error_screen.dart';
import 'package:frontend/screens/finish_signup.dart';
import 'package:frontend/screens/greeting.dart';
import 'package:frontend/screens/list_file_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/password_success.dart';
import 'package:frontend/screens/signup.dart';
import 'package:frontend/screens/upload_screen.dart';

import 'models/upload_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: GreetingScreen.routeName,
      onGenerateRoute: (RouteSettings settings){
        print('build route for ${settings.name}');
        var routes = <String, WidgetBuilder>{
          SignupScreen.routeName: (context) => const SignupScreen(),
          GreetingScreen.routeName: (context) => const GreetingScreen(),
          UploadScreen.routeName: (context) => const UploadScreen(),
          FinishSignupScreen.routeName: (context) => const FinishSignupScreen(),
          LoginScreen.routeName: (context) => const LoginScreen(),
          ErrorScreen.routeName: (context) => const ErrorScreen(),
          ListFileScreen.routeName: (context) => const ListFileScreen(),
          EnterPasswordScreen.routeName: (context) => EnterPasswordScreen(settings.arguments as FilePassword),
          PasswordSuccessScreen.routeName: (context) => const PasswordSuccessScreen(),
        };
        WidgetBuilder builder = routes[settings.name]!;
        return MaterialPageRoute(builder: (context) => builder(context));
      },
    );
    // return MaterialApp(
    //   title: 'Routes',
    //   initialRoute: ListFileScreen.routeName,
    //   routes: {
    //     SignupScreen.routeName: (context) => const SignupScreen(),
    //     GreetingScreen.routeName: (context) => const GreetingScreen(),
    //     UploadScreen.routeName: (context) => const UploadScreen(),
    //     FinishSignupScreen.routeName: (context) => const FinishSignupScreen(),
    //     LoginScreen.routeName: (context) => const LoginScreen(),
    //     ErrorScreen.routeName: (context) => const ErrorScreen(),
    //     ListFileScreen.routeName: (context) => const ListFileScreen(),
    //     EnterPasswordScreen.routeName: (context) => const EnterPasswordScreen(),
    //     PasswordSuccessScreen.routeName: (context) => const PasswordSuccessScreen(),
    //   }
    // );
  }
}
