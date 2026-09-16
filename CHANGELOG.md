## 1.0.1

* 新增 `auth()`：基于原生 `LoginWithHuaweiIDRequest` 的华为账号登录，支持
  `forceLogin`、`state`、`nonce` 和 `idTokenSignAlgorithm`。
* 调整 `authorize()`：基于原生 `AuthorizationWithHuaweiIDRequest`，新增
  `permissions` 参数（默认 `['idtoken', 'serviceauthcode']`），以便返回
  `authorizationCode` 与 `idToken`；`scopes` 默认值调整为 `['openid']`。
* `auth()` 由 `authorize()` 的别名改为执行登录请求，原调用方需改用
  `authorize()` 完成授权。
* `state` 未指定时由原生调用 `util.generateRandomUUID()` 生成，并随结果新增的
  `state` 字段返回给 Dart。
* 原生侧新增响应 `state` 与请求 `state` 的一致性校验，不一致时返回
  `state_mismatch`。
* Dart 侧新增 `state`/`nonce` 字符集与长度校验，`scopes` 与 `permissions`
  不能同时为空。

## 1.0.0

* Initial release.
* Support Huawei Account Kit authorization on HarmonyOS.
* Return authorization code, ID token, OpenID, and UnionID to Dart.
* Preserve native Account Kit error codes and messages in `PlatformException`.
