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
          };
        });
    platform = MethodChannelHuaweiKit();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  test('authorize sends the documented arguments and decodes result', () async {
    final HuaweiAuthResult response = await platform.authorize(
      scopes: const <String>['openid'],
      forceAuthorization: false,
      state: 'state-1',
      nonce: 'nonce-1',
      idTokenSignAlgorithm: HuaweiIdTokenSignAlgorithm.rs256,
    );

    expect(calls.single.method, 'authorize');
    expect(calls.single.arguments, <String, Object?>{
      'scopes': <String>['openid'],
      'forceAuthorization': false,
      'state': 'state-1',
      'nonce': 'nonce-1',
      'idTokenSignAlgorithm': 2,
    });
    expect(response.authorizationCode, 'authorization-code');
    expect(response.idToken, 'id-token');
    expect(response.openID, 'open-id');
    expect(response.unionID, 'union-id');
  });

  test('authorize uses Account Kit defaults', () async {
    await platform.authorize();

    expect(calls.single.arguments, <String, Object?>{
      'scopes': <String>['openid', 'profile'],
      'forceAuthorization': true,
      'idTokenSignAlgorithm': 1,
    });
  });

  test('auth is a compatible alias for the native auth method', () async {
    await platform.auth(scopes: const <String>['openid']);

    expect(calls.single.method, 'auth');
  });

  test('authorize rejects an empty scope list before native call', () async {
    await expectLater(
      platform.authorize(scopes: const <String>[]),
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
