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

  @override
  Future<HuaweiAuthResult> authorize({
    List<String> scopes = const <String>['openid', 'profile'],
    bool forceAuthorization = true,
    String? state,
    String? nonce,
    HuaweiIdTokenSignAlgorithm idTokenSignAlgorithm =
        HuaweiIdTokenSignAlgorithm.ps256,
  }) async {
    if (scopes.isEmpty || scopes.any((String scope) => scope.trim().isEmpty)) {
      throw ArgumentError.value(
        scopes,
        'scopes',
        'must contain at least one non-empty scope',
      );
    }

    return _invokeAuthorize(
      method: 'authorize',
      scopes: scopes,
      forceAuthorization: forceAuthorization,
      state: state,
      nonce: nonce,
      idTokenSignAlgorithm: idTokenSignAlgorithm,
    );
  }

  @override
  Future<HuaweiAuthResult> auth({
    List<String> scopes = const <String>['openid', 'profile'],
    bool forceAuthorization = true,
    String? state,
    String? nonce,
    HuaweiIdTokenSignAlgorithm idTokenSignAlgorithm =
        HuaweiIdTokenSignAlgorithm.ps256,
  }) {
    return _invokeAuthorize(
      method: 'auth',
      scopes: scopes,
      forceAuthorization: forceAuthorization,
      state: state,
      nonce: nonce,
      idTokenSignAlgorithm: idTokenSignAlgorithm,
    );
  }

  Future<HuaweiAuthResult> _invokeAuthorize({
    required String method,
    required List<String> scopes,
    required bool forceAuthorization,
    required String? state,
    required String? nonce,
    required HuaweiIdTokenSignAlgorithm idTokenSignAlgorithm,
  }) async {
    if (scopes.isEmpty || scopes.any((String scope) => scope.trim().isEmpty)) {
      throw ArgumentError.value(
        scopes,
        'scopes',
        'must contain at least one non-empty scope',
      );
    }

    final Map<Object?, Object?>? response = await methodChannel
        .invokeMethod<Map<Object?, Object?>>(method, <String, Object?>{
          'scopes': scopes,
          'forceAuthorization': forceAuthorization,
          if (state != null) 'state': state,
          if (nonce != null) 'nonce': nonce,
          'idTokenSignAlgorithm': idTokenSignAlgorithm.nativeValue,
        });
    if (response == null) {
      throw PlatformException(
        code: 'empty_response',
        message: 'Account Kit returned an empty authorization response',
      );
    }
    return HuaweiAuthResult.fromMap(response);
  }
}
