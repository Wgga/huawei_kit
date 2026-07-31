import UIAbility from '@ohos.app.ability.UIAbility';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@kit.BasicServicesKit';
import { authentication } from '@kit.AccountKit';
import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';

const CHANNEL_NAME: string = 'wgga.github.io/huawei_kit';

/** HarmonyOS implementation backed by Account Kit. */
export default class HuaweiKitPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
  private channel: MethodChannel | null = null;
  private ability: UIAbility | null = null;

  getUniqueClassName(): string {
    return 'HuaweiKitPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.ability = binding.getAbility();
  }

  onDetachedFromAbility(): void {
    this.ability = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    try {
      if (call.method === 'authorize' || call.method === 'auth') {
        this.authorize(call, result);
      } else {
        result.notImplemented();
      }
    } catch (error) {
      this.completeError(error, result);
    }
  }

  private authorize(call: MethodCall, result: MethodResult): void {
    const request: authentication.AuthorizationWithHuaweiIDRequest =
      new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    request.scopes = this.stringListArg(call, 'scopes');
    request.forceAuthorization = this.boolArg(call, 'forceAuthorization', true);

    const state: string | undefined = this.optionalStringArg(call, 'state');
    if (state !== undefined) {
      request.state = state;
    }
    const nonce: string | undefined = this.optionalStringArg(call, 'nonce');
    if (nonce !== undefined) {
      request.nonce = nonce;
    }
    request.idTokenSignAlgorithm = this.signAlgorithmArg(call);

    const controller: authentication.AuthenticationController =
      new authentication.AuthenticationController(this.requireAbilityContext());
    controller.executeRequest(request).then((response: authentication.AuthenticationResponse): void => {
      const authorizationResponse: authentication.AuthorizationWithHuaweiIDResponse =
        response as authentication.AuthorizationWithHuaweiIDResponse;
      const credential: authentication.AuthorizationWithHuaweiIDCredential | undefined =
        authorizationResponse.data;
      if (credential === undefined) {
        result.error('empty_response', 'Account Kit returned no authorization credential', null);
        return;
      }
      result.success({
        'authorizationCode': credential.authorizationCode,
        'idToken': credential.idToken,
        'openID': credential.openID,
        'unionID': credential.unionID,
      });
    }).catch((error: BusinessError): void => {
      this.completeError(error, result);
    });
  }

  private requireAbilityContext(): common.UIAbilityContext {
    if (this.ability === null) {
      throw new Error('huawei_kit requires a foreground UIAbility');
    }
    return this.ability.context;
  }

  private stringListArg(call: MethodCall, key: string): string[] {
    const value: ESObject = call.argument(key);
    if (!Array.isArray(value) || value.length === 0 ||
      !value.every((item: ESObject): boolean => typeof item === 'string' && item.trim().length > 0)) {
      throw new Error(`${key} must be a non-empty string array`);
    }
    return value as string[];
  }

  private optionalStringArg(call: MethodCall, key: string): string | undefined {
    const value: ESObject = call.argument(key);
    return typeof value === 'string' && value.length > 0 ? value : undefined;
  }

  private boolArg(call: MethodCall, key: string, defaultValue: boolean): boolean {
    const value: ESObject = call.argument(key);
    return typeof value === 'boolean' ? value : defaultValue;
  }

  private signAlgorithmArg(call: MethodCall): authentication.IdTokenSignAlgorithm {
    const value: ESObject = call.argument('idTokenSignAlgorithm');
    return value === 2 ? authentication.IdTokenSignAlgorithm.RS256 :
      authentication.IdTokenSignAlgorithm.PS256;
  }

  private errorMessage(error: ESObject): string {
    return error instanceof Error ? error.message : `${error}`;
  }

  private completeError(error: ESObject, result: MethodResult): void {
    const businessError: BusinessError = error as BusinessError;
    if (typeof businessError.code === 'number') {
      result.error(`${businessError.code}`, businessError.message, null);
      return;
    }
    result.error('huawei_kit_error', this.errorMessage(error), null);
  }
}
