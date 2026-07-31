import 'package:flutter_test/flutter_test.dart';
import 'package:huawei_kit/huawei_kit.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _FakeHuaweiKitPlatform extends HuaweiKitPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<HuaweiAuthResult> authorize({
    List<String> scopes = const <String>['openid', 'profile'],
    bool forceAuthorization = true,
    String? state,
    String? nonce,
    HuaweiIdTokenSignAlgorithm idTokenSignAlgorithm =
        HuaweiIdTokenSignAlgorithm.ps256,
  }) async {
    return const HuaweiAuthResult(openID: 'fake-open-id');
  }
}

void main() {
  test('HuaweiKit exposes the configured platform implementation', () async {
    final HuaweiKitPlatform original = HuaweiKitPlatform.instance;
    final _FakeHuaweiKitPlatform fake = _FakeHuaweiKitPlatform();
    addTearDown(() => HuaweiKitPlatform.instance = original);

    HuaweiKitPlatform.instance = fake;

    expect(HuaweiKit.instance, same(fake));
    expect((await HuaweiKit.instance.authorize()).openID, 'fake-open-id');
  });

  test('HuaweiAuthResult serializes all credential fields', () {
    const HuaweiAuthResult result = HuaweiAuthResult(
      authorizationCode: 'code',
      idToken: 'token',
      openID: 'open-id',
      unionID: 'union-id',
    );

    expect(result.toMap(), <String, String?>{
      'authorizationCode': 'code',
      'idToken': 'token',
      'openID': 'open-id',
      'unionID': 'union-id',
    });
    expect(result.toString(), isNot(contains('token')));
    expect(result.toString(), isNot(contains('code')));
  });
}
