# huawei_kit

[![Pub Package](https://img.shields.io/pub/v/huawei_kit.svg)](https://pub.dev/packages/huawei_kit)
[![License](https://img.shields.io/github/license/Wgga/huawei_kit)](https://github.com/Wgga/huawei_kit/blob/main/LICENSE)

华为 Account Kit 的 Flutter 插件，仅负责 HarmonyOS 原生账号登录与授权。

## 功能

- `auth()`：调用 `LoginWithHuaweiIDRequest` 完成华为账号登录；
- `authorize()`：调用 `AuthorizationWithHuaweiIDRequest` 完成华为账号授权；
- 向 Dart 返回 `authorizationCode`、`idToken`、`openID`、`unionID` 和本次使用的
  `state`；
- `state` 未指定时由原生用 `util.generateRandomUUID()` 生成；
- 校验响应 `state` 与请求 `state` 是否一致，防止跨站攻击；
- 将 Account Kit 的原生错误码和错误信息透传为 `PlatformException`；
- 支持自定义 `scopes`、`permissions`、`forceLogin`、`forceAuthorization`、
  `state`、`nonce` 和 ID Token 签名算法。

## 环境要求

- Dart `>=3.7.0 <4.0.0`
- Flutter `>=3.29.0`（HarmonyOS 分支）
- HarmonyOS API 12 或更高
- Stage 模型和前台 `UIAbility`

插件直接使用系统 `@kit.AccountKit`，不需要额外下载或内置 HAR。

## 安装

```yaml
dependencies:
  huawei_kit:
    git:
      url: https://github.com/Wgga/huawei_kit.git
```

## 宿主配置

1. 在 AppGallery Connect 创建或选择 HarmonyOS 应用并启用 Account Kit。
2. 配置与宿主一致的 `bundleName` 和应用签名证书指纹。
3. 确保应用使用 HarmonyOS 运行时，且 `compatibleSdkVersion` 不低于
   `5.0.0(12)`。
4. 使用前台 `UIAbility` 发起登录或授权。插件注册由 Flutter 自动完成，无需修改
   `EntryAbility`。

登录与授权是否成功依赖 AppGallery Connect 配置、设备登录状态、网络和所申请的
scope/permission。

## 使用

### 登录：`HuaweiKit.instance.auth()`

对应原生 `LoginWithHuaweiIDRequest`，用于获取当前设备上已登录华为账号的凭据。

```dart
import 'package:flutter/services.dart';
import 'package:huawei_kit/huawei_kit.dart';

try {
  final HuaweiAuthResult result = await HuaweiKit.instance.auth(
    forceLogin: true,
    state: 'your-random-state',
    nonce: 'your-random-nonce',
  );

  final String? openID = result.openID;
  final String? unionID = result.unionID;
  final String? state = result.state;
} on PlatformException catch (error) {
  final String errorCode = error.code;
  final String? errorMessage = error.message;
}
```

- `forceLogin` 默认 `true`：系统未登录华为账号时拉起登录页；设为 `false` 时不会
  拉起任何页面，直接返回错误码 `1001502001`；
- 登录请求不带 `scopes`，返回值通常只包含 `openID` 与 `unionID`；
- `state` 可不传，未传时由原生自动生成，并随结果的 `state` 字段返回。

### 授权：`HuaweiKit.instance.authorize()`

对应原生 `AuthorizationWithHuaweiIDRequest`，用于申请用户信息范围与服务权限。

```dart
try {
  final HuaweiAuthResult result = await HuaweiKit.instance.authorize(
    scopes: const <String>['openid', 'profile'],
    permissions: const <String>['idtoken', 'serviceauthcode'],
    forceAuthorization: true,
    state: 'your-random-state',
    nonce: 'your-random-nonce',
  );

  final String? authorizationCode = result.authorizationCode;
  final String? idToken = result.idToken;
  final String? openID = result.openID;
  final String? unionID = result.unionID;
  final String? state = result.state;
} on PlatformException catch (error) {
  final String errorCode = error.code;
  final String? errorMessage = error.message;
}
```

- `scopes` 默认 `['openid']`，决定可读取的用户信息范围，例如再加入 `profile`
  可获取头像昵称；
- `permissions` 默认 `['idtoken', 'serviceauthcode']`，其中 `serviceauthcode`
  决定是否返回 `authorizationCode`，`idtoken` 决定是否返回 `idToken`；
- `scopes` 与 `permissions` 不能同时为空，否则 Account Kit 返回 `1001502003`；
- `forceAuthorization` 默认 `true`：未登录拉起登录页，已登录未授权拉起授权页；
  设为 `false` 时未登录返回 `1001502001`，已登录但未授权返回 `1001502002`；
- `state` 可不传，未传时由原生自动生成，并随结果的 `state` 字段返回；
- ID Token 默认使用 `PS256`。

两个方法的返回字段均为可空类型，因为实际返回内容由 scope、permissions、权限和
Account Kit 响应决定。

传入的 `state` 和 `nonce` 需符合 Account Kit 的约束：长度 1-255，且只能包含
`0-9a-zA-Z:/._-`。`state` 不传时由原生生成；`nonce` 需要调用方自行生成不可预测
的值，并在服务端比对 ID Token 中的 `nonce` 声明。不要在客户端日志中输出
`authorizationCode` 或 `idToken`，也不要只依赖客户端返回值建立登录态；应将凭据
发送给服务端完成换取或验签。

## 错误处理

登录或授权失败会抛出 `PlatformException`：

- `code`：Account Kit 的原生错误码，例如用户取消为 `1001502012`；
- `message`：Account Kit 的原生错误信息；
- 响应 `state` 与请求 `state` 不一致时使用 `state_mismatch`；
- 插件自身参数或生命周期错误使用 `huawei_kit_error`；
- Account Kit 成功响应未包含凭据时使用 `empty_response`。

## 测试

```shell
flutter analyze
flutter test

cd example
flutter build hap --debug
```

HAP 打包前需在 DevEco Studio 中为 `example/ohos` 配置调试签名。登录与授权流程
必须在已配置 Account Kit 的 HarmonyOS 真机上验证。

## 官方资料

- [Account Kit](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-introduction)
- [华为账号授权](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-huawei-id)
- [Authentication API](https://developer.huawei.com/consumer/cn/doc/doccenter-references/api/account-api-authentication)

## License

MIT License
