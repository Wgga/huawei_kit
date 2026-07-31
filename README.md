# huawei_kit

[![Pub Package](https://img.shields.io/pub/v/huawei_kit.svg)](https://pub.dev/packages/huawei_kit)
[![License](https://img.shields.io/github/license/Wgga/huawei_kit)](https://github.com/Wgga/huawei_kit/blob/main/LICENSE)

华为 Account Kit 的 Flutter 插件，仅负责 HarmonyOS 原生账号授权。

## 功能

- 调用 `AuthorizationWithHuaweiIDRequest` 完成华为账号授权；
- 向 Dart 返回 `authorizationCode`、`idToken`、`openID` 和 `unionID`；
- 将 Account Kit 的原生错误码和错误信息透传为 `PlatformException`；
- 支持自定义 `scopes`、`forceAuthorization`、`state`、`nonce` 和 ID Token
  签名算法。

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
4. 使用前台 `UIAbility` 发起授权。插件注册由 Flutter 自动完成，无需修改
   `EntryAbility`。

账号授权是否成功依赖 AppGallery Connect 配置、设备登录状态、网络和所申请 scope。

## 使用

```dart
import 'package:flutter/services.dart';
import 'package:huawei_kit/huawei_kit.dart';

try {
  final HuaweiAuthResult result = await HuaweiKit.instance.authorize(
    scopes: const <String>['openid', 'profile'],
    forceAuthorization: true,
    state: 'your-random-state',
    nonce: 'your-random-nonce',
  );

  final String? authorizationCode = result.authorizationCode;
  final String? idToken = result.idToken;
  final String? openID = result.openID;
  final String? unionID = result.unionID;
} on PlatformException catch (error) {
  final String errorCode = error.code;
  final String? errorMessage = error.message;
}
```

默认 scope 为 `openid, profile`，默认强制拉起必要的登录/授权界面，ID Token
默认使用 `PS256`。字段均为可空类型，因为实际返回内容由 scope、权限和 Account Kit
响应决定。

生产环境应为每次请求生成不可预测的 `state` 和 `nonce`，并在服务端校验。不要在
客户端日志中输出 `authorizationCode` 或 `idToken`，也不要只依赖客户端返回值建立
登录态；应将凭据发送给服务端完成换取或验签。

## 错误处理

授权失败会抛出 `PlatformException`：

- `code`：Account Kit 的原生错误码，例如用户取消为 `1001502012`；
- `message`：Account Kit 的原生错误信息；
- 插件自身参数或生命周期错误使用 `huawei_kit_error`；
- Account Kit 成功响应未包含凭据时使用 `empty_response`。

## 测试

```shell
flutter analyze
flutter test

cd example
flutter build hap --debug
```

HAP 打包前需在 DevEco Studio 中为 `example/ohos` 配置调试签名。授权流程必须在已
配置 Account Kit 的 HarmonyOS 真机上验证。

## 官方资料

- [Account Kit](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-introduction)
- [华为账号授权](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-huawei-id)

## License

MIT License
