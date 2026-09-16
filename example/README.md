# huawei_kit_example

演示如何在 HarmonyOS Flutter 应用中调用 `huawei_kit` 完成华为账号登录与授权。

运行前需在 AppGallery Connect 中启用 Account Kit，并确保示例应用的
`bundleName`、签名证书指纹与后台配置一致。随后在 DevEco Studio 中配置调试签名，
从 HarmonyOS 真机运行：

- 点击 `Login` 调用 `HuaweiKit.instance.auth()`，对应 `LoginWithHuaweiIDRequest`；
- 点击 `Authorize` 调用 `HuaweiKit.instance.authorize()`，对应
  `AuthorizationWithHuaweiIDRequest`。
