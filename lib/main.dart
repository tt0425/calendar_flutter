// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jeffrey_dev/event_provider.dart';
import 'package:provider/provider.dart';
import 'calendar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    routes: {'/calendar': (context) => CalendarPage()},
    debugShowCheckedModeBanner: false,
    home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          if (snapshot.hasData) return CalendarPage();
          return LoginPage();
        }),
    theme: ThemeData.dark().copyWith(useMaterial3: true),
  ));
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// ref: https://dribbble.com/shots/18219801-Mobile-App-Login-Signup

  bool _visiblePw = false;

  String email = "";
  String password = "";

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print("weak password");
      } else if (e.code == "email-already-in-use") {
        print("email already in use");
      } else if (e.code == "invalid-email") {
        print("invalid-email");
      }
    } catch (e) {
      print(e);
    }
  }

  login({required String email, required String password}) {
    try {
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print(e);
    }
  }

  googleSignIn() async {
    await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
  }

  signInNameless() {
    FirebaseAuth.instance.signInAnonymously();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: FlutterLogo(
                    size: 200,
                  ),
                ),

                /// Email
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'hello@example.com',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => email = value,
                ),

                SizedBox(height: 32),

                /// Password
                TextField(
                  obscureText: _visiblePw,
                  onChanged: (value) => password = value,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Your password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _visiblePw = !_visiblePw),
                      icon: Icon(
                        _visiblePw ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 8),

                /// Forgot password
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Forgot Password?'),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 32),

                /// Login button
                CoverPageButton(
                  child: Text('Login',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  onTap: () => login(email: email, password: password),
                ),

                SizedBox(height: 8),

                /// Sign up button
                CoverPageButton(
                  backgroundColor: Colors.transparent,
                  child: Text(
                    'Register',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onTap: () => signUp(email: email, password: password),
                ),

                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey, height: 2)),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('OR', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey, height: 2)),
                  ],
                ),

                SizedBox(height: 16),

                // Continue with Google button
                CoverPageButton(
                  onTap: () => googleSignIn(),
                  backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                  child: Row(
                    children: [
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/2048px-Google_%22G%22_Logo.svg.png',
                        height: 24,
                      ),
                      Spacer(),
                      Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Continue anonymously button
                CoverPageButton(
                  onTap: () => signInNameless(),
                  backgroundColor: Colors.transparent,
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.white),
                      Spacer(),
                      Text('Continue anonymously',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CoverPageButton extends StatelessWidget {
  final Function()? onTap;
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double widthFactor;

  const CoverPageButton({
    Key? key,
    required this.onTap,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.grey,
    this.borderRadius = 5,
    this.widthFactor = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: OutlinedButton(
        onPressed: onTap,
        child: child,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
