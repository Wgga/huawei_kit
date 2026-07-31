import 'huawei_kit_platform_interface.dart';

export 'huawei_kit_platform_interface.dart';
export 'src/huawei_auth_result.dart';

/// HarmonyOS 华为账号授权入口。
abstract final class HuaweiKit {
  /// 当前平台实现。
  static HuaweiKitPlatform get instance => HuaweiKitPlatform.instance;
}
