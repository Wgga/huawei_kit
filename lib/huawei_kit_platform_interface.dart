import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'huawei_kit_method_channel.dart';
import 'src/huawei_auth_result.dart';

/// `huawei_kit` 的平台接口。
abstract class HuaweiKitPlatform extends PlatformInterface {
  /// 创建平台接口。
  HuaweiKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static HuaweiKitPlatform _instance = MethodChannelHuaweiKit();

  /// 当前平台实现，默认使用 MethodChannel。
  static HuaweiKitPlatform get instance => _instance;

  /// 设置平台实现。
  static set instance(HuaweiKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// 请求华为账号授权。
  ///
  /// 原生授权失败时抛出 `PlatformException`，其中 `code` 和 `message`
  /// 分别为 Account Kit 返回的错误码和错误信息。
  Future<HuaweiAuthResult> authorize({
    List<String> scopes = const <String>['openid', 'profile'],
    bool forceAuthorization = true,
    String? state,
    String? nonce,
    HuaweiIdTokenSignAlgorithm idTokenSignAlgorithm =
        HuaweiIdTokenSignAlgorithm.ps256,
  }) {
    throw UnimplementedError('authorize() has not been implemented.');
  }

  /// `authorize` 的兼容别名，与仓库中其他 kit 的登录 API 保持一致。
  Future<HuaweiAuthResult> auth({
    List<String> scopes = const <String>['openid', 'profile'],
    bool forceAuthorization = true,
    String? state,
    String? nonce,
    HuaweiIdTokenSignAlgorithm idTokenSignAlgorithm =
        HuaweiIdTokenSignAlgorithm.ps256,
  }) {
    return authorize(
      scopes: scopes,
      forceAuthorization: forceAuthorization,
      state: state,
      nonce: nonce,
      idTokenSignAlgorithm: idTokenSignAlgorithm,
    );
  }
}
