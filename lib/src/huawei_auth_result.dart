/// ID Token 使用的签名算法。
enum HuaweiIdTokenSignAlgorithm {
  /// RSASSA-PSS using SHA-256 and MGF1 with SHA-256。
  ps256(1),

  /// RSASSA-PKCS1-v1_5 using SHA-256。
  rs256(2);

  const HuaweiIdTokenSignAlgorithm(this.nativeValue);

  /// Account Kit 原生枚举值。
  final int nativeValue;
}

/// 华为账号授权成功后返回的凭据。
///
/// 字段是否存在由宿主应用申请的 scope、权限和 Account Kit 响应决定。
final class HuaweiAuthResult {
  /// 创建授权结果。
  const HuaweiAuthResult({
    this.authorizationCode,
    this.idToken,
    this.openID,
    this.unionID,
    this.state,
  });

  /// 从 MethodChannel 返回值创建授权结果。
  factory HuaweiAuthResult.fromMap(Map<Object?, Object?> map) {
    return HuaweiAuthResult(
      authorizationCode: map['authorizationCode'] as String?,
      idToken: map['idToken'] as String?,
      openID: map['openID'] as String?,
      unionID: map['unionID'] as String?,
      state: map['state'] as String?,
    );
  }

  /// 用于服务端换取 access token 的一次性授权码。
  final String? authorizationCode;

  /// 表示用户身份的 JWT。
  final String? idToken;

  /// 当前应用维度的用户唯一标识。
  final String? openID;

  /// 同一开发者账号下多个应用共享的用户唯一标识。
  final String? unionID;

  /// 本次请求使用的 `state`。
  ///
  /// 调用方未指定时由原生生成，可交给服务端做防重放校验。
  final String? state;

  /// 转换为 Map。
  Map<String, String?> toMap() => <String, String?>{
    'authorizationCode': authorizationCode,
    'idToken': idToken,
    'openID': openID,
    'unionID': unionID,
    'state': state,
  };

  @override
  String toString() {
    return 'HuaweiAuthResult('
        'authorizationCode: ${authorizationCode == null ? null : '***'}, '
        'idToken: ${idToken == null ? null : '***'}, '
        'openID: $openID, unionID: $unionID, state: $state)';
  }
}
