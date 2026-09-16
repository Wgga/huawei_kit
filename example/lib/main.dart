import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huawei_kit/huawei_kit.dart';

void main() {
  runApp(const HuaweiKitExampleApp());
}

class HuaweiKitExampleApp extends StatelessWidget {
  const HuaweiKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'huawei_kit example',
      theme: ThemeData(colorSchemeSeed: Colors.red),
      home: const AuthorizationPage(),
    );
  }
}

class AuthorizationPage extends StatefulWidget {
  const AuthorizationPage({super.key});

  @override
  State<AuthorizationPage> createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {
  String _status = 'Not authorized';
  String? _busyAction;

  Future<void> _run(
    String action,
    Future<HuaweiAuthResult> Function() request,
  ) async {
    setState(() {
      _busyAction = action;
      _status = '$action...';
    });

    try {
      final HuaweiAuthResult auth = await request();
      if (!mounted) {
        return;
      }
      setState(() {
        _status = <String>[
          '[$action]',
          'authorizationCode: ${auth.authorizationCode == null ? 'missing' : 'received'}',
          'idToken: ${auth.idToken == null ? 'missing' : 'received'}',
          'openID: ${auth.openID ?? 'missing'}',
          'unionID: ${auth.unionID ?? 'missing'}',
          'state: ${auth.state ?? 'missing'}',
        ].join('\n');
      });
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status =
            '[$action] Error ${error.code}: ${error.message ?? 'Unknown error'}';
      });
    } finally {
      if (mounted) {
        setState(() => _busyAction = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool busy = _busyAction != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Huawei Account Kit')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SelectableText(_status, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: busy
                    ? null
                    : () => _run('Login', () => HuaweiKit.instance.auth()),
                icon: busy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: const Text('Login'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: busy
                    ? null
                    : () => _run(
                          'Authorize',
                          () => HuaweiKit.instance.authorize(),
                        ),
                icon: const Icon(Icons.verified_user),
                label: const Text('Authorize'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
