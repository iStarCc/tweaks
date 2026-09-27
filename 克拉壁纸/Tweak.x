#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 克拉通过 App Group 在主 App 与扩展间共享偏好；Pro / 订阅 / 引导均读写此 suite
static NSString *const kClarityAppGroup = @"group.clarity";
static NSString *const kProUserKey = @"proUser";
static NSString *const kIsSubscriberKey = @"isSubscriber";
static NSString *const kExpiresDateStrKey = @"expiresDateStr";
// MainTabBar.viewDidLoad 读取：为 NO 时进入 Intro 流程；WhatsNew「开始使用」会写入 YES
static NSString *const kAppFirstLaunchKey = @"appFirstlaunch";

@interface IAPHelper : NSObject
- (BOOL)isPurchasedProductsIdentifier:(NSString *)identifier;
@end

@interface ClarityUntitInfo : NSObject
- (void)checkSubScribe;
- (BOOL)isProUser;
- (void)setIsProUser:(BOOL)pro;
- (BOOL)isSubscriber;
- (void)setIsSubscriber:(BOOL)subscriber;
@end

static NSUserDefaults *ClarityGroupDefaults(void) {
    return [[NSUserDefaults alloc] initWithSuiteName:kClarityAppGroup];
}

// checkSubScribe 用 NSDateFormatter 解析 expiresDateStr，格式须与官方字符串一致
static NSString *ClarityFarFutureExpireString(void) {
    static NSString *cached;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.year = 2099;
        components.month = 12;
        components.day = 31;
        components.hour = 23;
        components.minute = 59;
        components.second = 59;
        NSDate *date = [NSCalendar.currentCalendar dateFromComponents:components];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        cached = [formatter stringFromDate:date] ?: @"2099-12-31 23:59:59";
    });
    return cached;
}

// 持久化「已完成首次引导」，使 MainTabBar 走已引导分支而非 Intro 初始化
static void ClarityMarkOnboardingComplete(void) {
    NSUserDefaults *defaults = ClarityGroupDefaults();
    if (!defaults) return;
    [defaults setBool:YES forKey:kAppFirstLaunchKey];
    [defaults synchronize];
}

// 写入 Pro 三件套：内存单例 init 与 checkSubScribe 均依赖这些键
static void ClarityApplyProDefaults(void) {
    NSUserDefaults *defaults = ClarityGroupDefaults();
    if (!defaults) return;

    [defaults setBool:YES forKey:kProUserKey];
    [defaults setBool:YES forKey:kIsSubscriberKey];
    [defaults setObject:ClarityFarFutureExpireString() forKey:kExpiresDateStrKey];
    ClarityMarkOnboardingComplete();
    [defaults synchronize];
}

// MainTabBar.viewDidAppear 会以 modal 方式 present 的引导类名
static BOOL ClarityIsOnboardingViewController(UIViewController *vc) {
    if (!vc) return NO;
    NSString *name = NSStringFromClass([vc class]);
    static NSSet<NSString *> *blocked;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blocked = [NSSet setWithArray:@[
            @"WhatsNewViewController",
            @"IntroViewController",
            @"IntroLetterLegacyViewController",
        ]];
    });
    return [blocked containsObject:name];
}

// 除 UserDefaults 外，TabBar 还用 hadShowGuid / guideShowed 控制是否再弹 WhatsNew
static void ClaritySkipMainTabOnboardingFlags(id tabBar) {
    if (!tabBar) return;
    if ([tabBar respondsToSelector:@selector(setHadShowGuid:)]) {
        [tabBar setValue:@YES forKey:@"hadShowGuid"];
    }
    if ([tabBar respondsToSelector:@selector(guideShowed)]) {
        [tabBar performSelector:@selector(guideShowed)];
    }
}

// ClarityUntitInfo 单例字段与 defaults 双写，避免仅改磁盘、内存仍为旧值
static void ClarityApplyProFlags(id untitInfo) {
    if (!untitInfo) return;
    if ([untitInfo respondsToSelector:@selector(setIsProUser:)]) {
        [(ClarityUntitInfo *)untitInfo setIsProUser:YES];
    }
    if ([untitInfo respondsToSelector:@selector(setIsSubscriber:)]) {
        [(ClarityUntitInfo *)untitInfo setIsSubscriber:YES];
    }
}

#pragma mark - 内购：IAPHelper 本地购买查询

// UI 与功能门控在收据校验之外，仍会调用 isPurchasedProductsIdentifier 查 Keychain；
// 返回 YES 即可通过本地「是否已购」判断（不替代 StoreKit 服务端逻辑）。
%hook IAPHelper

- (BOOL)isPurchasedProductsIdentifier:(NSString *)identifier {
    (void)identifier;
    return YES;
}

%end

#pragma mark - 订阅：ClarityUntitInfo + App Group

%hook ClarityUntitInfo

// 先写 defaults，再执行官方过期比较，最后同步内存 ivar
- (void)checkSubScribe {
    ClarityApplyProDefaults();
    %orig;
    ClarityApplyProFlags(self);
}

// 多处 UI 直接读 getter，与 defaults 并行生效
- (BOOL)isProUser {
    return YES;
}

- (BOOL)isSubscriber {
    return YES;
}

%end

#pragma mark - 引导：MainTabBar + WhatsNew

@interface MainTabBarViewController : UITabBarController
- (void)guideShowed;
- (void)setHadShowGuid:(BOOL)shown;
@end

@interface WhatsNewViewController : UIViewController
@end

%hook MainTabBarViewController

- (void)viewDidLoad {
    ClarityMarkOnboardingComplete();
    %orig;
    ClaritySkipMainTabOnboardingFlags(self);
}

- (void)viewDidAppear:(BOOL)animated {
    ClarityMarkOnboardingComplete();
    ClaritySkipMainTabOnboardingFlags(self);
    %orig;
}

// 在 present 入口短路：不创建引导 UI，completion 仍回调以免调用方阻塞
- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated:(BOOL)flag
                   completion:(void (^)(void))completion {
    if (ClarityIsOnboardingViewController(viewControllerToPresent)) {
        ClarityMarkOnboardingComplete();
        ClaritySkipMainTabOnboardingFlags(self);
        if (completion) completion();
        return;
    }
    %orig;
}

%end

%hook WhatsNewViewController

- (void)viewDidLoad {
    %orig;
    ClarityMarkOnboardingComplete();
    // present 拦截失败时的二次保护
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    });
}

%end

// 进程加载时预写 Group，减少首帧竞态（TabBar 尚未创建）
%ctor {
    ClarityApplyProDefaults();
}
