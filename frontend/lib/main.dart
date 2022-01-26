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

import 'constants.dart';
import 'models/upload_model.dart';

void main() {
  runApp(const MyApp());
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    String? route;
    Map? queryParameters;
    if (settings.name != null) {
      var uriData = Uri.parse(settings.name!);
      route = uriData.path;
      queryParameters = uriData.queryParameters;
    }
    var message = '$route $queryParameters';
    print(message);
    return MaterialPageRoute(
        builder: (context) {
          return LoginScreen();
        },
        settings: settings,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: GreetingScreen.routeName,
      onGenerateRoute: (RouteSettings settings) {
        print('build route for ${settings.name}');
        var routes = <String, WidgetBuilder>{
          SignupScreen.routeName: (context) => const SignupScreen(),
          GreetingScreen.routeName: (context) => const GreetingScreen(),
          UploadScreen.routeName: (context) => const UploadScreen(),
          FinishSignupScreen.routeName: (context) => const FinishSignupScreen(),
          LoginScreen.routeName: (context) => const LoginScreen(),
          ErrorScreen.routeName: (context) => const ErrorScreen(),
          ListFileScreen.routeName: (context) => ListFileScreen(
              settings.arguments == null ? listUploadUrl : settings.arguments as String),
          EnterPasswordScreen.routeName: (context) =>
              EnterPasswordScreen(settings.arguments as FilePassword),
          PasswordSuccessScreen.routeName: (context) =>
              const PasswordSuccessScreen(),
        };
        WidgetBuilder builder = routes[settings.name]!;
        return MaterialPageRoute(builder: (context) => builder(context));
      },
    );
  }
}
