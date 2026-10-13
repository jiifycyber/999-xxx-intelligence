import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/war_room_screen.dart';
import 'services/cipher_backend_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? auth.currentSession;

        if (session != null) {
          return AuthenticatedCipherShell(
            key: ValueKey(session.user.id),
          );
        }

        return const CipherLoginScreen();
      },
    );
  }
}

class AuthenticatedCipherShell extends StatefulWidget {
  const AuthenticatedCipherShell({super.key});

  @override
  State<AuthenticatedCipherShell> createState() =>
      _AuthenticatedCipherShellState();
}

class _AuthenticatedCipherShellState extends State<AuthenticatedCipherShell> {
  bool _backendReady = false;
  String? _backendError;

  @override
  void initState() {
    super.initState();
    _initializeBackend();
  }

  Future<void> _initializeBackend() async {
    try {
      await CipherBackendService.instance.registerDeviceAndStartSession();

      if (!mounted) return;

      setState(() {
        _backendReady = true;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _backendError = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_backendError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF05080D),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 60,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'SECURE BACKEND INITIALIZATION FAILED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _backendError!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _backendError = null;
                      });
                      _initializeBackend();
                    },
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_backendReady) {
      return const Scaffold(
        backgroundColor: Color(0xFF05080D),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 18),
              Text('REGISTERING SECURE DEVICE...'),
            ],
          ),
        ),
      );
    }

    return const WarRoomScreen();
  }
}

class CipherLoginScreen extends StatefulWidget {
  const CipherLoginScreen({super.key});

  @override
  State<CipherLoginScreen> createState() => _CipherLoginScreenState();
}

class _CipherLoginScreenState extends State<CipherLoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;
  bool createAccount = false;
  bool obscure = true;
  String? message;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final userEmail = email.text.trim();
    final userPassword = password.text;

    if (userEmail.isEmpty || userPassword.length < 6) {
      setState(() {
        message =
            'Enter a valid email and a password of at least 6 characters.';
      });
      return;
    }

    setState(() {
      loading = true;
      message = null;
    });

    try {
      final auth = Supabase.instance.client.auth;

      if (createAccount) {
        final result = await auth.signUp(
          email: userEmail,
          password: userPassword,
        );

        if (!mounted) return;

        if (result.session == null) {
          setState(() {
            message = 'Account created. Check your email for confirmation.';
          });
        }
      } else {
        await auth.signInWithPassword(
          email: userEmail,
          password: userPassword,
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      setState(() {
        message = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        message = 'Authentication failed.';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05080D),
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/ic391_login_background.png'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          child: SafeArea(
            child: Align(
              alignment: const Alignment(0, 0.86),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xDD0B1118),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF244451),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        TextField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: password,
                          obscureText: obscure,
                          autocorrect: false,
                          enableSuggestions: false,
                          onSubmitted: (_) {
                            if (!loading) submit();
                          },
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscure = !obscure;
                                });
                              },
                              icon: Icon(
                                obscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ),
                        if (message != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            message!,
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 22),
                        FilledButton(
                          onPressed: loading ? null : submit,
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'SIGN IN',
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
