#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <execinfo.h>

@interface QNListItem : NSObject
- (BOOL)isAdvertisement;
- (BOOL)isVideoAd;
- (BOOL)isMontageAd;
- (BOOL)isTAD;
- (id)adItem;
@end

@interface QNTableViewAdapter : NSObject
- (id)p_dataAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface CNewsAdBaseCell : UITableViewCell @end
@interface CNewsAdBottomFloatView : UIView @end
@interface QNAdBrandGiftFloatView : UIView @end
@interface QNDetailBannerAdView : UIView @end
@interface QNDetailPicAdView : UIView @end
@interface QNDetailNewNormalAdView : UIView @end
@interface QNDetailRelateAdCell : UITableViewCell @end
@interface QNDetailRelateNewAdCell : UITableViewCell @end
@interface QNDetailRelateCollectionAdCard : UIView @end
@interface QNArticleContentTopBannerAdView : UIView @end
@interface QNDetailSpecialSmallAdView : UIView @end
@interface QNDetailNFTBannerAdView : UIView @end
@interface QNDetailPortraitAdView : UIView @end
@interface QNDetailGameAdView : UIView @end
@interface QNDetailBottomBanner : UIView @end
@interface QNSSPAdCommentCell : UITableViewCell @end

@interface QNCPRecommendVerticalCell : UITableViewCell @end
@interface QNCPRecommendVerticalCellModel : NSObject
- (void)setRect:(CGRect)rect;
@end
@interface QNListMorePersonalRecommendCell : UITableViewCell @end
@interface QNListMorePersonalRecommendCellModel : NSObject
- (void)setRect:(CGRect)rect;
@end

static BOOL isAdData(id data) {
    if (!data) return NO;
    if ([data respondsToSelector:@selector(isAdvertisement)]) {
        return [(QNListItem *)data isAdvertisement];
    }
    if ([data respondsToSelector:@selector(adItem)]) {
        return [(QNListItem *)data adItem] != nil;
    }
    return NO;
}


// ============================================================
// MARK: - 1. 开屏广告
// ============================================================

%hook QNSplashAdManager
- (BOOL)shouldShowTADSplashAdAndPreloadIfNeeded { return NO; }
- (BOOL)_shouldShowTADSplashAd { return NO; }
- (BOOL)_shouldUseTADSplashAd { return NO; }
- (void)showSplashAdWithAdWillDisplay:(id)a didDisplaySplash:(id)b willDismissSplash:(id)c dismissSplashEnd:(void(^)(void))end { if (end) end(); }
- (BOOL)showSplashAdInHotLaunchingWithDismissSplashEnd:(void(^)(void))end { if (end) end(); return NO; }
+ (BOOL)IsSplashAdShowing { return NO; }
- (BOOL)splashIsShowing { return NO; }
%end

%hook AmsSplashWindow
+ (BOOL)showSplashAd:(id)a LaunchView:(id)b LogoView:(id)c adSkipButton:(id)d { return NO; }
- (void)showSplash {}
+ (BOOL)IsSplashAdShowing { return NO; }
%end


// ============================================================
// MARK: - 2. 信息流广告 — TableView Delegate 终极拦截
// ============================================================

%hook QNTableViewAdapter

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        id data = [self p_dataAtIndexPath:indexPath];
        if (isAdData(data)) return 0;
    } @catch (NSException *e) {}
    return %orig;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = %orig;
    @try {
        id data = [self p_dataAtIndexPath:indexPath];
        if (isAdData(data)) {
            cell.hidden = YES;
            cell.clipsToBounds = YES;
        }
    } @catch (NSException *e) {}
    return cell;
}

%end

%hook QNComposeAdCell
+ (double)heightForData:(id)data width:(double)w context:(id)ctx { return 0; }
+ (id)cellSizeWithListItem:(id)item { return nil; }
- (void)layoutWithData:(id)data context:(id)ctx {
    [(UITableViewCell *)self setHidden:YES];
    [(UITableViewCell *)self setFrame:CGRectZero];
}
- (void)cellWillDisplay { [(UITableViewCell *)self setHidden:YES]; }
%end

%hook CNewsAdBaseCell
+ (double)getCellHeight:(id)item row:(long long)row isNoPicMode:(BOOL)noPic Style:(unsigned long long)style context:(id)ctx containerWidth:(double)w { return 0; }
+ (double)textModeCellHeight:(id)item containerWidth:(double)w { return 0; }
+ (double)newStyleV7CellHeight:(id)item containerWidth:(double)w { return 0; }
+ (double)largePicCellHeight:(id)item containerWidth:(double)w { return 0; }
- (void)cellWillDisplay { self.hidden = YES; self.clipsToBounds = YES; }
- (void)layoutSubviews { self.hidden = YES; }
%end

%hook CSectionItemType
- (void)insertAdListItem:(id)item atIndex:(NSUInteger)index {}
%end

%hook QNNewsTimelineListModel
- (void)_insertAdItemWithIsInFirstPage:(BOOL)first useFirstBigImageConfigure:(BOOL)bigImg extendData:(id)data validPosItems:(id)items allStickedItemDict:(id)dict {}
%end

%hook CNewsAdBottomFloatManager
- (BOOL)showFullScreenAdView:(id)v fullscreen:(BOOL)f { return NO; }
- (BOOL)isAdViewShowing { return NO; }
%end

%hook CNewsAdBottomFloatView
- (void)layoutSubviews { self.hidden = YES; }
%end

%hook QNAdBrandGiftFloatView
- (void)layoutSubviews { self.hidden = YES; }
%end

%hook QNAdBreakFrameManager
- (void)showBreakFrameAd:(id)ad {}
%end


// ============================================================
// MARK: - 推荐用户模块
// ============================================================

%hook QNCPRecommendVerticalCellModel
- (void)calculateWithData:(id)data referRect:(CGRect)rect context:(id)ctx {
    %orig;
    [self setRect:CGRectZero];
}
%end

%hook QNCPRecommendVerticalCell
- (void)layoutWithViewModel:(id)vm context:(id)ctx {
    self.hidden = YES;
    self.clipsToBounds = YES;
    self.frame = CGRectZero;
}
%end

%hook QNListMorePersonalRecommendCellModel
- (void)calculateWithData:(id)data referRect:(CGRect)rect context:(id)ctx {
    %orig;
    [self setRect:CGRectZero];
}
%end

%hook QNListMorePersonalRecommendCell
- (void)layoutWithViewModel:(id)vm context:(id)ctx {
    self.hidden = YES;
    self.clipsToBounds = YES;
    self.frame = CGRectZero;
}
%end


// ============================================================
// MARK: - 3. 详情页广告
// ============================================================

%hook QNDetailComponentAd
- (BOOL)shouldQueryEntireDetailAd { return NO; }
- (void)refreshAdUI {}
- (void)controllerDidReceiveDataAndWillRenderHTML {}
- (void)controllerDidReceiveRelateNewsData {}
%end

%hook QNDetailRelateAdCell
+ (double)heightForData:(id)data width:(double)w context:(id)ctx { return 0; }
- (void)layoutWithData:(id)data context:(id)ctx {}
- (void)cellWillDisplay { self.hidden = YES; }
- (void)layoutSubviews { self.frame = CGRectZero; self.hidden = YES; }
%end

%hook QNDetailRelateNewAdCell
+ (double)heightForData:(id)data width:(double)w context:(id)ctx { return 0; }
- (void)layoutWithData:(id)data context:(id)ctx {}
- (void)cellWillDisplay { self.hidden = YES; }
- (void)layoutSubviews { self.frame = CGRectZero; self.hidden = YES; }
%end

%hook QNDetailRelateCollectionAdCard
- (void)layoutSubviews { self.hidden = YES; [self setFrame:CGRectZero]; }
%end

%hook QNDetailPicAdView
+ (double)_imageHeight:(id)item containerWidth:(double)w { return 0; }
- (void)setFoldAd:(BOOL)fold {}
- (void)layoutSubviews { self.hidden = YES; [self setFrame:CGRectZero]; }
%end

%hook QNDetailNewNormalAdView
+ (double)viewHeightWithADItem:(id)item maxWidth:(double)w { return 0; }
- (void)layoutSubviews { self.hidden = YES; [self setFrame:CGRectZero]; }
%end

%hook QNDetailBannerAdView
- (void)layoutSubviews { self.hidden = YES; [self setFrame:CGRectZero]; }
%end

%hook QNDetailNFTBannerAdView
- (void)layoutSubviews { self.hidden = YES; [self setFrame:CGRectZero]; }
%end

%hook QNArticleContentTopBannerAdView
- (void)layoutSubviews { self.hidden = YES; [self setFrame:CGRectZero]; }
%end

%hook QNDetailSpecialSmallAdView
- (void)layoutSubviews { self.hidden = YES; [self setFrame:CGRectZero]; }
%end

%hook QNDetailPortraitAdView
- (void)layoutSubviews { self.hidden = YES; [self setFrame:CGRectZero]; }
%end

%hook QNDetailGameAdView
- (void)layoutSubviews { self.hidden = YES; [self setFrame:CGRectZero]; }
%end

%hook QNDetailBottomBanner
- (void)layoutSubviews { self.hidden = YES; [self setFrame:CGRectZero]; }
%end

// 文章中间广告: 阻止对象创建
%hook QNArticleCompanionAdItem
- (id)init { return nil; }
%end

%hook QNArticleContentMidAdNode
- (id)init { return nil; }
%end

%hook QNArticleMidInsertGameAdNode
- (id)init { return nil; }
%end

%hook QNDetailMidAdCloudGameManager
- (void)showCloudGameFloatView:(id)view {}
%end

%hook QNSSPAdCommentCell
+ (double)heightForData:(id)data width:(double)w context:(id)ctx { return 0; }
- (void)layoutSubviews { self.hidden = YES; self.frame = CGRectZero; }
%end

%hook CNewsAdDetailBottomBar
- (void)layoutSubviews {
    [(UIView *)self setHidden:YES];
    [(UIView *)self setFrame:CGRectZero];
}
%end


// ============================================================
// MARK: - TVK 鉴权：GUID + Bundle + Keychain
// ============================================================

static NSString * const kGUIDKey = @"repo.om2.cc.qqnews.tw.guid";
static NSString * const kKCPrefix = @"repo.om2.cc.qqnews.tw.kc.";
static NSString * const kOfficialBundleID = @"com.tencent.info";

static BOOL gSpoofBundleForTVK = NO;

static BOOL TVKCallerMatches(const char *needle) {
    if (!needle) return NO;
    void *frames[16];
    int count = backtrace(frames, 16);
    for (int i = 0; i < count; i++) {
        Dl_info info = {0};
        if (!dladdr(frames[i], &info) || !info.dli_sname) continue;
        if (strstr(info.dli_sname, needle)) return YES;
    }
    return NO;
}

static NSString *TVKForgeGUID(void) {
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    NSString *guid = [ud stringForKey:kGUIDKey];
    if (guid.length) return guid;

    guid = NSUUID.UUID.UUIDString;
    guid = [[guid stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    if (guid.length != 32) {
        guid = [[NSUUID.UUID.UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    }
    [ud setObject:guid forKey:kGUIDKey];
    [ud synchronize];
    return guid;
}

static id TVKKeychainFallback(NSString *key) {
    if (!key.length) return nil;
    return [NSUserDefaults.standardUserDefaults objectForKey:[kKCPrefix stringByAppendingString:key]];
}

static BOOL TVKIsUserDefaultsSafe(id value) {
    if (!value) return NO;
    if ([value isKindOfClass:[NSString class]] ||
        [value isKindOfClass:[NSNumber class]] ||
        [value isKindOfClass:[NSData class]] ||
        [value isKindOfClass:[NSDate class]]) {
        return YES;
    }
    if ([value isKindOfClass:[NSArray class]]) {
        for (id item in (NSArray *)value) {
            if (!TVKIsUserDefaultsSafe(item)) return NO;
        }
        return YES;
    }
    if ([value isKindOfClass:[NSDictionary class]]) {
        for (id item in ((NSDictionary *)value).allValues) {
            if (!TVKIsUserDefaultsSafe(item)) return NO;
        }
        return YES;
    }
    return NO;
}

static void TVKKeychainFallbackSave(NSString *key, id value) {
    if (![key isKindOfClass:[NSString class]] || !key.length || !value) return;
    if (!TVKIsUserDefaultsSafe(value)) return;
    @try {
        [NSUserDefaults.standardUserDefaults setObject:value
                                                forKey:[kKCPrefix stringByAppendingString:key]];
    } @catch (__unused NSException *e) {}
}

#pragma mark - Bundle ID 欺骗 (仅 TVK 鉴权栈)

%hook NSBundle

- (NSString *)bundleIdentifier {
    NSString *bid = %orig;
    if (gSpoofBundleForTVK) return kOfficialBundleID;
    if (TVKCallerMatches("TVKAuthenticator") ||
        TVKCallerMatches("TVKSDKParams") ||
        TVKCallerMatches("TVKVcSystemInfo") ||
        TVKCallerMatches("QNTVKPlayer") ||
        TVKCallerMatches("TVKCGI") ||
        TVKCallerMatches("TVKBatchVinfo") ||
        TVKCallerMatches("TVKVinfo") ||
        TVKCallerMatches("Vinfo") ||
        TVKCallerMatches("ThumbPlayer") ||
        TVKCallerMatches("TVKPlay")) {
        if (![bid isEqualToString:kOfficialBundleID]) {
            return kOfficialBundleID;
        }
    }
    return bid;
}

%end

#pragma mark - GUID 伪造

%hook TVKVcSystemInfo

- (NSString *)getGUIDFromKeychain {
    NSString *guid = %orig;
    if (guid.length) return guid;
    return TVKForgeGUID();
}

- (NSString *)localGuid {
    NSString *guid = %orig;
    if (guid.length) return guid;
    return TVKForgeGUID();
}

- (void)updateLocalGuid:(NSString *)guid {
    if (guid.length) {
        [NSUserDefaults.standardUserDefaults setObject:guid forKey:kGUIDKey];
        TVKKeychainFallbackSave(@"tvk_local_guid", guid);
    }
    %orig;
}

- (NSString *)deviceId {
    NSString *did = %orig;
    if (did.length) return did;
    return TVKForgeGUID();
}

%end

%hook TVKSDKParamsMgr

- (NSString *)guid {
    NSString *g = %orig;
    if (g.length) return g;
    return TVKForgeGUID();
}

- (void)setGuid:(NSString *)guid external:(BOOL)external {
    if (!guid.length) guid = TVKForgeGUID();
    %orig;
}

%end

%hook BeaconBaseInterface

+ (void)setGUID:(NSString *)guid {
    if (!guid.length) guid = TVKForgeGUID();
    %orig;
}

%end

%hook TVKBeaconBaseInterface

+ (void)setGUID:(NSString *)guid {
    if (!guid.length) guid = TVKForgeGUID();
    %orig;
}

%end

#pragma mark - Keychain 降级存储

%hook QNKeychainAccess

- (id)objectValueForKey:(NSString *)key {
    id value = %orig;
    if (!value) value = TVKKeychainFallback(key);
    return value;
}

- (BOOL)saveObjectValue:(id)value forKey:(NSString *)key {
    BOOL ok = %orig;
    if (!ok) TVKKeychainFallbackSave(key, value);
    return ok;
}

%end

#pragma mark - TVK 鉴权绕过

%hook TVKAuthenticator

- (void)updateAuthStatusWithAppKey:(NSString *)appKey {
    gSpoofBundleForTVK = YES;
    @try {
        %orig;
    } @finally {
        gSpoofBundleForTVK = NO;
    }
    @try {
        [(id)self setValue:@(1) forKey:@"authStatus"];
    } @catch (__unused NSException *e) {}
}

- (id)authStatusWithInfo:(id)info {
    id result = %orig;
    if (!result) {
        return @{@"status": @1, @"valid": @YES};
    }
    return result;
}

%end

static void TVKRefreshAuth(void) {
    gSpoofBundleForTVK = YES;
    @try {
        Class paramsCls = NSClassFromString(@"TVKSDKParamsMgr");
        Class authCls = NSClassFromString(@"TVKAuthenticator");
        if (!paramsCls || !authCls) return;

        id params = [paramsCls performSelector:@selector(shareInstance)];
        NSString *appKey = nil;
        if ([params respondsToSelector:@selector(appKey)]) {
            appKey = [params performSelector:@selector(appKey)];
        }
        if (!appKey.length) {
            @try { appKey = [params valueForKey:@"_appKey"]; } @catch (__unused NSException *e) {}
        }
        if (!appKey.length) return;

        id auth = [[authCls alloc] init];
        [auth performSelector:@selector(updateAuthStatusWithAppKey:) withObject:appKey];
    } @catch (__unused NSException *e) {}
    gSpoofBundleForTVK = NO;
}

%hook QNTVKPlayerReceiveImpl

- (void)authErrorHandleWithErrorModel:(id)errorModel errorCode:(NSInteger)errorCode {
    if (errorCode == 10101001) {
        TVKRefreshAuth();
    }
    %orig;
}

%end

#pragma mark - 启动时预置 GUID + 鉴权

%hook QNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL ret = %orig;
    NSString *guid = TVKForgeGUID();

    Class beacon = NSClassFromString(@"TVKBeaconBaseInterface");
    if (beacon && [beacon respondsToSelector:@selector(setGUID:)]) {
        [beacon performSelector:@selector(setGUID:) withObject:guid];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TVKRefreshAuth();
    });
    return ret;
}

%end

%ctor {
    (void)TVKForgeGUID();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TVKRefreshAuth();
    });
}
