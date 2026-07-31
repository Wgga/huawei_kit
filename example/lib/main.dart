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
  bool _authorizing = false;

  Future<void> _authorize() async {
    setState(() {
      _authorizing = true;
      _status = 'Authorizing...';
    });

    try {
      final HuaweiAuthResult auth = await HuaweiKit.instance.authorize();
      if (!mounted) {
        return;
      }
      setState(() {
        _status = <String>[
          'authorizationCode: ${auth.authorizationCode == null ? 'missing' : 'received'}',
          'idToken: ${auth.idToken == null ? 'missing' : 'received'}',
          'openID: ${auth.openID ?? 'missing'}',
          'unionID: ${auth.unionID ?? 'missing'}',
        ].join('\n');
      });
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = 'Error ${error.code}: ${error.message ?? 'Unknown error'}';
      });
    } finally {
      if (mounted) {
        setState(() => _authorizing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: _authorizing ? null : _authorize,
                icon: _authorizing
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: const Text('Authorize'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
