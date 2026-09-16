import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'huawei_kit_platform_interface.dart';
import 'src/huawei_auth_result.dart';

/// 使用 MethodChannel 的 HarmonyOS 实现。
class MethodChannelHuaweiKit extends HuaweiKitPlatform {
  /// 与原生插件通信的 MethodChannel。
  @visibleForTesting
  final MethodChannel methodChannel = const MethodChannel(
    'wgga.github.io/huawei_kit',
  );

  /// Account Kit 对 `state`/`nonce` 的字符集与长度限制。
  static final RegExp _stateOrNoncePattern = RegExp(r'^[0-9a-zA-Z:/.\-_]{1,255}$');

  @override
  Future<HuaweiAuthResult> auth({
    bool forceLogin = true,
    String? state,
    String? nonce,
    HuaweiIdTokenSignAlgorithm idTokenSignAlgorithm =
        HuaweiIdTokenSignAlgorithm.ps256,
  }) {
    _validateStateOrNonce('state', state);
    _validateStateOrNonce('nonce', nonce);

    return _invoke(
      method: 'auth',
      arguments: <String, Object?>{
        'forceLogin': forceLogin,
        if (state != null) 'state': state,
        if (nonce != null) 'nonce': nonce,
        'idTokenSignAlgorithm': idTokenSignAlgorithm.nativeValue,
      },
    );
  }

  @override
  Future<HuaweiAuthResult> authorize({
    List<String> scopes = const <String>['openid'],
    List<String> permissions = const <String>['idtoken', 'serviceauthcode'],
    bool forceAuthorization = true,
    String? state,
    String? nonce,
    HuaweiIdTokenSignAlgorithm idTokenSignAlgorithm =
        HuaweiIdTokenSignAlgorithm.ps256,
  }) {
    if (scopes.isEmpty && permissions.isEmpty) {
      throw ArgumentError(
        'scopes and permissions must not both be empty',
      );
    }
    _validateStringList('scopes', scopes);
    _validateStringList('permissions', permissions);
    _validateStateOrNonce('state', state);
    _validateStateOrNonce('nonce', nonce);

    return _invoke(
      method: 'authorize',
      arguments: <String, Object?>{
        if (scopes.isNotEmpty) 'scopes': scopes,
        if (permissions.isNotEmpty) 'permissions': permissions,
        'forceAuthorization': forceAuthorization,
        if (state != null) 'state': state,
        if (nonce != null) 'nonce': nonce,
        'idTokenSignAlgorithm': idTokenSignAlgorithm.nativeValue,
      },
    );
  }

  Future<HuaweiAuthResult> _invoke({
    required String method,
    required Map<String, Object?> arguments,
  }) async {
    final Map<Object?, Object?>? response = await methodChannel
        .invokeMethod<Map<Object?, Object?>>(method, arguments);
    if (response == null) {
      throw PlatformException(
        code: 'empty_response',
        message: 'Account Kit returned an empty authorization response',
      );
    }
    return HuaweiAuthResult.fromMap(response);
  }

  void _validateStringList(String name, List<String> values) {
    if (values.any((String value) => value.trim().isEmpty)) {
      throw ArgumentError.value(
        values,
        name,
        'must not contain empty entries',
      );
    }
  }

  void _validateStateOrNonce(String name, String? value) {
    if (value == null) {
      return;
    }
    if (!_stateOrNoncePattern.hasMatch(value)) {
      throw ArgumentError.value(
        value,
        name,
        r'must match ^[0-9a-zA-Z:/.\-_]{1,255}$',
      );
    }
  }
}
