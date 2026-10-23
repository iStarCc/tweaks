#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

/**
 * TXDocsNoSplashAd — 腾讯文档 iOS 开屏广告屏蔽
 *
 * 策略：
 * 1. GDT 链路：hook showGDTAdIfNeeded:result: 直接完成，不初始化 GDTAdSaler。
 * 2. GDT 链路补充：hook showGDTAdIfNeeded（无参数版）同样直接标记完成。
 * 3. GDT 查询：hook gdtSplashAdIsShown:result: 返回 isShown=NO。
 * 4. 天枢链路：hook _TtC6Runner16TDSplashAdHelper.fetchTianshuSplashData 空操作。
 * 5. 天枢数据查询：hook _TtC6Runner13AdBlockPlugin.splashData 返回 nil。
 */

static void finishGDTAdImmediately(void) {
    Class adMgrCls = objc_getClass("TDAdManager");
    if (!adMgrCls) return;
    id mgr = ((id (*)(id, SEL))objc_msgSend)(adMgrCls, sel_registerName("shareInstance"));
    if (!mgr) return;
    ((void (*)(id, SEL, BOOL))objc_msgSend)(mgr, sel_registerName("setGdtFinished:"), YES);

    Class chCls = objc_getClass("TDMessageChannel");
    if (!chCls) return;
    id ch = ((id (*)(id, SEL))objc_msgSend)(chCls, sel_registerName("sharedInstance"));
    if (ch) {
        ((void (*)(id, SEL))objc_msgSend)(ch, sel_registerName("notifySplashAdClosed"));
    }
}

// ─── 1/2/3. TDMessageChannel hooks ──────────────────────────

%hook TDMessageChannel

- (void)showGDTAdIfNeeded:(id)info result:(void (^)(id))result {
    finishGDTAdImmediately();
    if (result) {
        result(@{@"_call_result": @"success"});
    }
}

- (void)showGDTAdIfNeeded {
    finishGDTAdImmediately();
}

- (void)gdtSplashAdIsShown:(id)info result:(void (^)(id))result {
    if (result) {
        result(@{@"isShown": @NO});
    }
}

%end

// ─── 4. 天枢: fetchTianshuSplashData ────────────────────────

%hook _TtC6Runner16TDSplashAdHelper

+ (void)fetchTianshuSplashData {
}

%end

// ─── 5. 天枢数据拦截: AdBlockPlugin.splashData ──────────────

%hook _TtC6Runner13AdBlockPlugin

- (NSDictionary *)splashData {
    return nil;
}

%end
