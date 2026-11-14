import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/home_screen.dart';
import '../screens/signin_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<Session?>(
      stream: auth.onAuthStateChange.map((state) => state.session),
      initialData: auth.currentSession,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const SignInPage();
        }
        return HomeScreen();
      },
    );
  }
}
