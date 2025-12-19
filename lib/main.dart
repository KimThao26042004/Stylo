// import 'package:flutter/material.dart';
// import 'views/auth_screen/login_screen.dart';
// import 'views/auth_screen/signUp_screen.dart';
// import 'views/auth_screen/forgotPass_screen.dart';
// import 'views/auth_screen/VerificationCode_screen.dart';
// import 'views/auth_screen/ResetPass_screen.dart';
// import 'views/home_screen/home_screen.dart';
// import 'views/profile_screen/account_screen.dart';
// import 'views/order_screen/myOrders_screen.dart';
// import 'views/order_screen/trackOrder_screen.dart';
// import 'views/cart_screen/address_screen.dart';
// import 'views/cart_screen/cart_screen.dart';
// import 'views/cart_screen/checkout_screen.dart';
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Fashion Shop',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
//         fontFamily: 'Roboto',
//       ),
//       // initialRoute: LoginScreen.routeName,
//       home: const HomeScreen(),
//       routes: {
//         LoginScreen.routeName: (_) => const LoginScreen(),
//         SignUpScreen.routeName: (_) => const SignUpScreen(),
//         ForgotPassScreen.routeName: (_) => const ForgotPassScreen(),
//         ResetPassScreen.routeName: (_) => const ResetPassScreen(),
//         HomeScreen.routeName: (_) => const HomeScreen(),
//       },
//       onGenerateRoute: (settings) {
//         if (settings.name == VerificationCodeScreen.routeName) {
//           final email = settings.arguments as String? ?? '';
//           return MaterialPageRoute(
//             builder: (_) => VerificationCodeScreen(email: email),
//           );
//         }
//         return null;
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'state/auth_provider.dart';
import 'state/account_provider.dart';
import 'state/product_provider.dart';

import 'views/auth_screen/login_screen.dart';
import 'views/auth_screen/signUp_screen.dart';
import 'views/auth_screen/forgotPass_screen.dart';
import 'views/auth_screen/VerificationCode_screen.dart';
import 'views/auth_screen/ResetPass_screen.dart';
import 'views/home_screen/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService()),
        ),

        ChangeNotifierProvider(
          create: (_) => AccountProvider(),
        ),

        ChangeNotifierProvider(
            create: (_) => ProductProvider(),
        ),
      ],
      child: const MyApp(),
    ),

  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fashion Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        fontFamily: 'Roboto',
      ),

      //  dùng initialRoute thay vì home để quản lý điều hướng rõ ràng
      initialRoute: LoginScreen.routeName,

      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignUpScreen.routeName: (_) => const SignUpScreen(),
        ForgotPassScreen.routeName: (_) => const ForgotPassScreen(),
        ResetPassScreen.routeName: (_) => const ResetPassScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == VerificationCodeScreen.routeName) {
          final args = settings.arguments as Map?;
          final email = args?['email'] ?? '';
          final flow  = args?['flow'] ?? 'signup';

          return MaterialPageRoute(
            builder: (_) => VerificationCodeScreen(
              email: email,
              flow: flow,
            ),
          );
        }
        return null;
      },
    );
  }
}
