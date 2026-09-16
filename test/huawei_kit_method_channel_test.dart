import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huawei_kit/huawei_kit.dart';
import 'package:huawei_kit/huawei_kit_method_channel.dart';

const MethodChannel _channel = MethodChannel('wgga.github.io/huawei_kit');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelHuaweiKit platform;
  late List<MethodCall> calls;

  setUp(() {
    calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (MethodCall call) async {
          calls.add(call);
          return <String, Object?>{
            'authorizationCode': 'authorization-code',
            'idToken': 'id-token',
            'openID': 'open-id',
            'unionID': 'union-id',
            'state': 'generated-state',
          };
        });
    platform = MethodChannelHuaweiKit();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  test('auth sends the documented login arguments and decodes result', () async {
    final HuaweiAuthResult response = await platform.auth(
      forceLogin: false,
      state: 'state-1',
      nonce: 'nonce-1',
      idTokenSignAlgorithm: HuaweiIdTokenSignAlgorithm.rs256,
    );

    expect(calls.single.method, 'auth');
    expect(calls.single.arguments, <String, Object?>{
      'forceLogin': false,
      'state': 'state-1',
      'nonce': 'nonce-1',
      'idTokenSignAlgorithm': 2,
    });
    expect(response.authorizationCode, 'authorization-code');
    expect(response.idToken, 'id-token');
    expect(response.openID, 'open-id');
    expect(response.unionID, 'union-id');
    expect(response.state, 'generated-state');
  });

  test('auth uses Account Kit login defaults', () async {
    await platform.auth();

    expect(calls.single.method, 'auth');
    expect(calls.single.arguments, <String, Object?>{
      'forceLogin': true,
      'idTokenSignAlgorithm': 1,
    });
  });

  test('authorize sends the documented authorization arguments', () async {
    final HuaweiAuthResult response = await platform.authorize(
      scopes: const <String>['openid'],
      permissions: const <String>['idtoken'],
      forceAuthorization: false,
      state: 'state-1',
      nonce: 'nonce-1',
      idTokenSignAlgorithm: HuaweiIdTokenSignAlgorithm.rs256,
    );

    expect(calls.single.method, 'authorize');
    expect(calls.single.arguments, <String, Object?>{
      'scopes': <String>['openid'],
      'permissions': <String>['idtoken'],
      'forceAuthorization': false,
      'state': 'state-1',
      'nonce': 'nonce-1',
      'idTokenSignAlgorithm': 2,
    });
    expect(response.openID, 'open-id');
    expect(response.state, 'generated-state');
  });

  test('authorize uses Account Kit authorization defaults', () async {
    await platform.authorize();

    expect(calls.single.method, 'authorize');
    expect(calls.single.arguments, <String, Object?>{
      'scopes': <String>['openid'],
      'permissions': <String>['idtoken', 'serviceauthcode'],
      'forceAuthorization': true,
      'idTokenSignAlgorithm': 1,
    });
  });

  test('authorize omits an empty scope list when permissions are present', () async {
    await platform.authorize(
      scopes: const <String>[],
      permissions: const <String>['serviceauthcode'],
    );

    expect(calls.single.arguments, <String, Object?>{
      'permissions': <String>['serviceauthcode'],
      'forceAuthorization': true,
      'idTokenSignAlgorithm': 1,
    });
  });

  test('authorize rejects empty scopes and permissions before native call', () {
    expect(
      () => platform.authorize(
        scopes: const <String>[],
        permissions: const <String>[],
      ),
      throwsArgumentError,
    );
    expect(calls, isEmpty);
  });

  test('auth rejects a malformed state before native call', () {
    expect(
      () => platform.auth(state: 'invalid state'),
      throwsArgumentError,
    );
    expect(calls, isEmpty);
  });

  test('authorize preserves native error code and message', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (MethodCall call) async {
          throw PlatformException(
            code: '1001502012',
            message: 'The user canceled the authorization',
          );
        });

    await expectLater(
      platform.authorize(),
      throwsA(
        isA<PlatformException>()
            .having(
              (PlatformException error) => error.code,
              'code',
              '1001502012',
            )
            .having(
              (PlatformException error) => error.message,
              'message',
              'The user canceled the authorization',
            ),
      ),
    );
  });
}
