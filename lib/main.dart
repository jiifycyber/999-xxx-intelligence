import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import 'core/genesis_theme.dart';
import 'auth_gate.dart';
import 'widgets/ic391_premium_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://msyisjoserdtubpbfhyo.supabase.co',
    publishableKey: 'sb_publishable_iSXHWJ_ipQeI1sLKzLO0HA_3zsxlmkn',
  );

  runApp(const GenesisProtocolApp());
}

class GenesisProtocolApp extends StatelessWidget {
  const GenesisProtocolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UNITED NATIONS OF IC-391',
      theme: GenesisTheme.dark,
      home: const IC391PremiumTheme(child: AuthGate()),
    );
  }
}
