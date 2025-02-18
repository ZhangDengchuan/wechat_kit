import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';
import 'package:wechat_kit/wechat_kit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('v7lin.github.io/wechat_kit');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'registerApp':
          return null;
        case 'isInstalled':
          return true;
        case 'isSupportApi':
          return true;
        case 'openWechat':
          return true;
        case 'auth':
          unawaited(channel.binaryMessenger.handlePlatformMessage(
            channel.name,
            channel.codec.encodeMethodCall(MethodCall(
                'onAuthResp',
                json.decode(
                    '{"country":"CN","code":null,"errorCode":-2,"state":null,"lang":"zh_CN","errorMsg":null}'))),
            (ByteData? data) {
              print('mock ${channel.name} ${call.method}');
            },
          ));
          return null;
        case 'startQrauth':
        case 'stopQrauth':
          throw PlatformException(code: '0', message: '懒得去mock');
        case 'openUrl':
        case 'openRankList':
          throw PlatformException(code: '0', message: '懒得去mock');
        case 'shareText':
        case 'shareImage':
        case 'shareEmoji':
        case 'shareMusic':
        case 'shareVideo':
        case 'shareWebpage':
        case 'shareMiniProgram':
          unawaited(channel.binaryMessenger.handlePlatformMessage(
            channel.name,
            channel.codec.encodeMethodCall(MethodCall('onShareMsgResp',
                json.decode('{"errorCode":0,"errorMsg":null}'))),
            (ByteData? data) {
              print('mock ${channel.name} ${call.method}');
            },
          ));
          return null;
        case 'subscribeMsg':
        case 'launchMiniProgram':
          throw PlatformException(code: '0', message: '懒得去mock');
        case 'pay':
          unawaited(channel.binaryMessenger.handlePlatformMessage(
            channel.name,
            channel.codec.encodeMethodCall(MethodCall(
                'onPayResp',
                json.decode(
                    '{"errorCode":-2,"returnKey":"","errorMsg":null}'))),
            (ByteData? data) {
              print('mock ${channel.name} ${call.method}');
            },
          ));
          return null;
      }
      throw PlatformException(code: '0', message: '想啥呢，升级插件不想升级Mock？');
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('isInstalled', () async {
    expect(await Wechat.instance.isInstalled(), true);
  });

  test('isSupportApi', () async {
    expect(await Wechat.instance.isSupportApi(), true);
  });

  test('auth', () async {
    final StreamSubscription<BaseResp> subs =
        Wechat.instance.respStream().listen((BaseResp resp) {
      expect(resp.runtimeType, AuthResp);
      expect(resp.errorCode, BaseResp.ERRORCODE_USERCANCEL);
    });
    await Wechat.instance.auth(
      scope: <String>[
        WechatScope.SNSAPI_USERINFO,
      ],
    );
    await Future<void>.delayed(const Duration(seconds: 1));
    await subs.cancel();
  });

  test('share', () async {
    final StreamSubscription<BaseResp> subs =
        Wechat.instance.respStream().listen((BaseResp resp) {
      expect(resp.runtimeType, ShareMsgResp);
      expect(resp.errorCode, BaseResp.ERRORCODE_SUCCESS);
    });
    await Wechat.instance.shareText(
      scene: WechatScene.SESSION,
      text: 'share text',
    );
    await Future<void>.delayed(const Duration(seconds: 1));
    await subs.cancel();
  });

  test('pay', () async {
    final StreamSubscription<BaseResp> subs =
        Wechat.instance.respStream().listen((BaseResp resp) {
      expect(resp.runtimeType, PayResp);
      expect(resp.errorCode, BaseResp.ERRORCODE_USERCANCEL);
    });
    await Wechat.instance.pay(
      appId: 'mock',
      partnerId: 'mock',
      prepayId: 'mock',
      package: 'mock',
      nonceStr: 'mock',
      timeStamp: 'mock',
      sign: 'mock',
    );
    await Future<void>.delayed(const Duration(seconds: 1));
    await subs.cancel();
  });
}
