import UIAbility from '@ohos.app.ability.UIAbility';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@kit.BasicServicesKit';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
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
      if (call.method === 'auth') {
        this.login(call, result);
      } else if (call.method === 'authorize') {
        this.authorize(call, result);
      } else {
        result.notImplemented();
      }
    } catch (error) {
      this.completeError(error, result);
    }
  }

  /** Huawei ID login backed by `LoginWithHuaweiIDRequest`. */
  private login(call: MethodCall, result: MethodResult): void {
    const request: authentication.LoginWithHuaweiIDRequest =
      new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
    request.forceLogin = this.boolArg(call, 'forceLogin', true);
    request.state = this.optionalStringArg(call, 'state') ?? util.generateRandomUUID();
    const nonce: string | undefined = this.optionalStringArg(call, 'nonce');
    if (nonce !== undefined) {
      request.nonce = nonce;
    }
    request.idTokenSignAlgorithm = this.signAlgorithmArg(call);

    const controller: authentication.AuthenticationController =
      new authentication.AuthenticationController(this.requireAbilityContext());
    controller.executeRequest(request)
      .then((response: authentication.AuthenticationResponse): void => {
        const loginResponse: authentication.LoginWithHuaweiIDResponse =
          response as authentication.LoginWithHuaweiIDResponse;
        if (!this.checkState(request.state, loginResponse.state, result)) {
          return;
        }
        const credential: authentication.LoginWithHuaweiIDCredential | undefined =
          loginResponse.data;
        if (credential === undefined) {
          result.error('empty_response', 'Account Kit returned no login credential', null);
          return;
        }
        result.success({
          'authorizationCode': credential.authorizationCode,
          'idToken': credential.idToken,
          'openID': credential.openID,
          'unionID': credential.unionID,
          'state': request.state,
        });
      })
      .catch((error: BusinessError): void => {
        this.completeError(error, result);
      });
  }

  /** Huawei ID authorization backed by `AuthorizationWithHuaweiIDRequest`. */
  private authorize(call: MethodCall, result: MethodResult): void {
    const request: authentication.AuthorizationWithHuaweiIDRequest =
      new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    const scopes: string[] | undefined = this.optionalStringListArg(call, 'scopes');
    const permissions: string[] | undefined = this.optionalStringListArg(call, 'permissions');
    if (scopes === undefined && permissions === undefined) {
      throw new Error('scopes and permissions must not both be empty');
    }
    if (scopes !== undefined) {
      request.scopes = scopes;
    }
    if (permissions !== undefined) {
      request.permissions = permissions;
    }
    request.forceAuthorization = this.boolArg(call, 'forceAuthorization', true);
    request.state = this.optionalStringArg(call, 'state') ?? util.generateRandomUUID();
    const nonce: string | undefined = this.optionalStringArg(call, 'nonce');
    if (nonce !== undefined) {
      request.nonce = nonce;
    }
    request.idTokenSignAlgorithm = this.signAlgorithmArg(call);

    const controller: authentication.AuthenticationController =
      new authentication.AuthenticationController(this.requireAbilityContext());
    controller.executeRequest(request)
      .then((response: authentication.AuthenticationResponse): void => {
        const authorizationResponse: authentication.AuthorizationWithHuaweiIDResponse =
          response as authentication.AuthorizationWithHuaweiIDResponse;
        if (!this.checkState(request.state, authorizationResponse.state, result)) {
          return;
        }
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
          'state': request.state,
        });
      })
      .catch((error: BusinessError): void => {
        this.completeError(error, result);
      });
  }

  /** Compares the response state with the request state to prevent CSRF. */
  private checkState(
    requestState: string | undefined,
    responseState: string | undefined,
    result: MethodResult,
  ): boolean {
    if ((requestState ?? '') !== (responseState ?? '')) {
      result.error(
        'state_mismatch',
        'The response state does not match the request state',
        null,
      );
      return false;
    }
    return true;
  }

  private requireAbilityContext(): common.UIAbilityContext {
    if (this.ability === null) {
      throw new Error('huawei_kit requires a foreground UIAbility');
    }
    return this.ability.context;
  }

  private optionalStringListArg(call: MethodCall, key: string): string[] | undefined {
    const value: ESObject = call.argument(key);
    if (value === undefined || value === null) {
      return undefined;
    }
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
