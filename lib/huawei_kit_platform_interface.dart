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

  /// 发起华为账号登录，对应原生的 `LoginWithHuaweiIDRequest`。
  ///
  /// 与仓库中其他 kit 的登录 API 保持一致，用于获取当前设备上已登录华为账号
  /// 的凭据。
  ///
  /// [forceLogin] 为 `true` 时，系统未登录华为账号会拉起登录页；为 `false`
  /// 时不会拉起任何页面，直接返回错误码 `1001502001`。不带 `scopes`，因此
  /// 返回值通常只包含 `openID` 与 `unionID`。
  ///
  /// [state] 未指定时由原生生成，并随结果中的 `state` 字段返回。
  ///
  /// 原生登录失败时抛出 `PlatformException`，其中 `code` 和 `message`
  /// 分别为 Account Kit 返回的错误码和错误信息；响应 `state` 与请求 `state`
  /// 不一致时抛出 `code` 为 `state_mismatch` 的 `PlatformException`。
  Future<HuaweiAuthResult> auth({
    bool forceLogin = true,
    String? state,
    String? nonce,
    HuaweiIdTokenSignAlgorithm idTokenSignAlgorithm =
        HuaweiIdTokenSignAlgorithm.ps256,
  }) {
    throw UnimplementedError('auth() has not been implemented.');
  }

  /// 发起华为账号授权，对应原生的 `AuthorizationWithHuaweiIDRequest`。
  ///
  /// [scopes] 用于申请需要读取的用户信息范围，例如 `openid`、`profile`；
  /// [permissions] 用于申请用户授权码和身份凭证，可选 `serviceauthcode`
  /// （响应中返回 `authorizationCode`）与 `idtoken`（响应中返回 `idToken`）。
  /// 两者不能同时为空，否则 Account Kit 返回 `1001502003`。
  ///
  /// [forceAuthorization] 为 `true` 时，系统未登录或未授权都会拉起对应页面；
  /// 为 `false` 时未登录返回 `1001502001`，已登录但未授权返回 `1001502002`。
  ///
  /// [state] 未指定时由原生生成，并随结果中的 `state` 字段返回。
  ///
  /// 原生授权失败时抛出 `PlatformException`，其中 `code` 和 `message`
  /// 分别为 Account Kit 返回的错误码和错误信息；响应 `state` 与请求 `state`
  /// 不一致时抛出 `code` 为 `state_mismatch` 的 `PlatformException`。
  Future<HuaweiAuthResult> authorize({
    List<String> scopes = const <String>['openid'],
    List<String> permissions = const <String>['idtoken', 'serviceauthcode'],
    bool forceAuthorization = true,
    String? state,
    String? nonce,
    HuaweiIdTokenSignAlgorithm idTokenSignAlgorithm =
        HuaweiIdTokenSignAlgorithm.ps256,
  }) {
    throw UnimplementedError('authorize() has not been implemented.');
  }
}
