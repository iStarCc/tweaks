#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import "poster_data.h"

int __isOSVersionAtLeast(int major, int minor, int patch) {
    NSOperatingSystemVersion version = {major, minor, patch};
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:version];
}

// ============================================================
// 类声明
// ============================================================

@interface CNLaunchSplashViewController : UIViewController
@end

@interface CNAdRecommendAdsViewController : UIViewController
@end

@interface DXTemplateItem : NSObject
- (NSString *)name;
- (BOOL)isAvailable;
- (BOOL)isAvailableForDownload;
@end

@interface CNBDinamicXCardModel : NSObject
- (DXTemplateItem *)origTemplate;
- (DXTemplateItem *)fetchedTemplateItem;
- (DXTemplateItem *)finalFetchedTemplateItem;
@end

@interface CNGPackageListDinamicXModel : NSObject
- (DXTemplateItem *)dxItem;
- (double)viewHeight;
- (Class)viewClass;
@end

@interface CNGPackageListDXModel : NSObject
- (CNBDinamicXCardModel *)cardModel;
- (double)viewHeight;
- (Class)viewClass;
@end

@interface CNBHomeViewController : UIViewController
@end

@interface CNLDControllerLifeCycleHandler : NSObject
@end

@interface CNNewLDTemplateContentView : UIView
- (UIScrollView *)logisticsScrollView;
- (BOOL)showMapView;
- (BOOL)hasChangedOffset;
- (double)logisticsScrollBestContentOffsetY;
- (void)setLogisticsScrollBestContentOffsetY:(double)y;
@end

// ============================================================
// 设置管理
// ============================================================

static NSString * const kSettingsSuite = @"com.cainiao.adremover";

typedef NS_ENUM(NSInteger, CARSettingKey) {
    CARSettingSplashAd = 0,
    CARSettingNewUserZone,
    CARSettingBanner,
    CARSettingPromotion,
    CARSettingRecommend,
    CARSettingAdRequest,
    CARSettingFeedsAd,
    CARSettingMineActivity,
    CARSettingLDRecommend,
    CARSettingLDBanner,
    CARSettingIconRow,
    CARSettingHideExchange,
    CARSettingHideDiscover,
    CARSettingHideMessage,
    CARSettingHideCoupon,
    CARSettingAutoReadMessage,
    CARSettingCount
};

// 各设置分组的起始 key，分组内的行数由相邻起始 key 之差决定
static const CARSettingKey kSectionStartKeys[] = {CARSettingSplashAd, CARSettingIconRow, CARSettingAutoReadMessage, CARSettingCount};
static NSString * const kSectionTitles[] = {@"广告拦截", @"界面隐藏（仅隐藏 UI）", @"自动化"};

static NSString * const kSettingKeys[] = {
    [CARSettingSplashAd]    = @"block_splash_ad",
    [CARSettingNewUserZone] = @"block_new_user_zone",
    [CARSettingBanner]      = @"block_banner",
    [CARSettingPromotion]   = @"block_promotion",
    [CARSettingRecommend]   = @"block_recommend",
    [CARSettingAdRequest]   = @"block_ad_request",
    [CARSettingFeedsAd]     = @"block_feeds_ad",
    [CARSettingMineActivity] = @"block_mine_activity",
    [CARSettingLDRecommend] = @"block_ld_recommend",
    [CARSettingLDBanner]    = @"block_ld_banner",
    [CARSettingIconRow]     = @"block_icon_row",
    [CARSettingHideExchange] = @"hide_exchange",
    [CARSettingHideDiscover] = @"hide_discover",
    [CARSettingHideMessage]  = @"hide_message",
    [CARSettingHideCoupon]   = @"hide_coupon",
    [CARSettingAutoReadMessage] = @"auto_read_message",
};

static NSString * const kSettingTitles[] = {
    [CARSettingSplashAd]    = @"开屏广告拦截",
    [CARSettingNewUserZone] = @"新用户专区拦截",
    [CARSettingBanner]      = @"首页横幅拦截",
    [CARSettingPromotion]   = @"运营推广拦截",
    [CARSettingRecommend]   = @"猜你喜欢拦截",
    [CARSettingAdRequest]   = @"广告请求拦截",
    [CARSettingFeedsAd]     = @"Feeds 广告拦截",
    [CARSettingMineActivity] = @"我的页推广拦截",
    [CARSettingLDRecommend] = @"物流详情推荐拦截",
    [CARSettingLDBanner]    = @"物流详情横幅拦截",
    [CARSettingIconRow]     = @"首页图标栏隐藏",
    [CARSettingHideExchange] = @"隐藏物换物",
    [CARSettingHideDiscover] = @"隐藏底栏发现",
    [CARSettingHideMessage]  = @"隐藏底栏消息",
    [CARSettingHideCoupon]   = @"隐藏底栏寄件券",
    [CARSettingAutoReadMessage] = @"消息页自动一键已读",
};

static NSString * const kSettingSubtitles[] = {
    [CARSettingSplashAd]    = @"启动时的全屏广告",
    [CARSettingNewUserZone] = @"首页「新用户专区」卡片",
    [CARSettingBanner]      = @"首页顶部横幅广告",
    [CARSettingPromotion]   = @"首页运营推广内容",
    [CARSettingRecommend]   = @"底部「猜你喜欢」推荐",
    [CARSettingAdRequest]   = @"阻止广告网络请求",
    [CARSettingFeedsAd]     = @"信息流中的广告内容",
    [CARSettingMineActivity] = @"「我的」页「热门活动」卡片及「每日首次添加包裹有奖」横幅",
    [CARSettingLDRecommend] = @"物流详情页底部「猜你喜欢」推荐及子标签页",
    [CARSettingLDBanner]    = @"物流详情页横幅广告及品牌弹窗广告",
    [CARSettingIconRow]     = @"取包裹/寄包裹等快捷入口及包裹分类标签头",
    [CARSettingHideExchange] = @"底栏「物换物」入口，剩余项自动等分",
    [CARSettingHideDiscover] = @"底栏「发现」入口，剩余项自动等分",
    [CARSettingHideMessage]  = @"底栏「消息」入口，剩余项自动等分",
    [CARSettingHideCoupon]   = @"底栏「寄件券」入口，剩余项自动等分",
    [CARSettingAutoReadMessage] = @"切换到消息页时自动点击右上角「一键已读」",
};

static BOOL isSettingEnabled(CARSettingKey key) {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kSettingsSuite];
    NSString *settingKey = kSettingKeys[key];
    id value = [defaults objectForKey:settingKey];
    if (!value) return key < CARSettingIconRow; // 广告拦截默认开启，界面隐藏默认关闭
    return [defaults boolForKey:settingKey];
}

static void setSettingEnabled(CARSettingKey key, BOOL enabled) {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kSettingsSuite];
    [defaults setBool:enabled forKey:kSettingKeys[key]];
    [defaults synchronize];
}

// ============================================================
// 视图文字提取
// ============================================================

static NSString *car_viewText(UIView *view) {
    NSString *text = nil;
    if ([view isKindOfClass:[UILabel class]]) text = ((UILabel *)view).text;
    else if ([view isKindOfClass:[UIButton class]]) text = [(UIButton *)view titleForState:UIControlStateNormal];
    return text.length ? text : view.accessibilityLabel;
}

// ============================================================
// 设置页面 ViewController
// ============================================================

@interface CainiaoAdRemoverSettingsVC : UITableViewController
@end

@implementation CainiaoAdRemoverSettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"菜鸟优化";
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0);
    self.tableView.separatorColor = [UIColor colorWithWhite:0.85 alpha:1];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.contentInset = UIEdgeInsetsMake(-8, 0, 0, 0);
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    static NSData *sPosterData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sPosterData = [[NSData alloc] initWithBase64EncodedString:kCARPosterBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    });
    UIImage *posterImage = sPosterData ? [UIImage imageWithData:sPosterData] : nil;
    if (posterImage) {
        CGFloat aspectRatio = posterImage.size.height / posterImage.size.width;
        CGFloat posterHeight = screenWidth * aspectRatio;
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, posterHeight)];
        header.backgroundColor = [UIColor whiteColor];
        UIImageView *posterView = [[UIImageView alloc] initWithImage:posterImage];
        posterView.frame = CGRectMake(0, 0, screenWidth, posterHeight);
        posterView.contentMode = UIViewContentModeScaleAspectFill;
        posterView.clipsToBounds = YES;
        posterView.userInteractionEnabled = YES;
        [posterView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(car_openRepo)]];
        [header addSubview:posterView];
        self.tableView.tableHeaderView = header;
    }

    static NSString * const kDisclaimer = @"免责声明：本插件仅供技术学习与研究，请于下载后 24 小时内删除。使用本插件造成的一切后果由用户自行承担，与开发者无关。切换设置后需重启 App 生效。";
    UIView *footerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 36)];
    footerContainer.clipsToBounds = YES;

    UIFont *footerFont = [UIFont systemFontOfSize:11];
    CGSize textSize = [kDisclaimer sizeWithAttributes:@{NSFontAttributeName: footerFont}];
    CGFloat labelWidth = textSize.width + 60;

    UILabel *scrollLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth, 10, labelWidth, 16)];
    scrollLabel.text = kDisclaimer;
    scrollLabel.font = footerFont;
    scrollLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1];
    scrollLabel.tag = 0x4D5152; // marquee tag
    [footerContainer addSubview:scrollLabel];
    self.tableView.tableFooterView = footerContainer;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sizeof(kSectionTitles) / sizeof(kSectionTitles[0]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kSectionStartKeys[section + 1] - kSectionStartKeys[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    CARSettingKey key = (CARSettingKey)(kSectionStartKeys[indexPath.section] + indexPath.row);
    cell.textLabel.text = kSettingTitles[key];
    cell.detailTextLabel.text = kSettingSubtitles[key];
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    cell.backgroundColor = [UIColor whiteColor];

    UISwitch *sw = [[UISwitch alloc] init];
    sw.on = isSettingEnabled(key);
    sw.tag = key;
    [sw addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = sw;

    return cell;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIView *footer = self.tableView.tableFooterView;
    UILabel *scrollLabel = [footer viewWithTag:0x4D5152];
    if (!scrollLabel || scrollLabel.layer.animationKeys.count) return;

    CGFloat screenW = footer.bounds.size.width;
    CGFloat labelW = scrollLabel.bounds.size.width;
    CGFloat duration = (screenW + labelW) / 50.0;

    scrollLabel.frame = CGRectMake(screenW, scrollLabel.frame.origin.y, labelW, scrollLabel.frame.size.height);
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    anim.fromValue = @0;
    anim.toValue = @(-(screenW + labelW));
    anim.duration = duration;
    anim.repeatCount = HUGE_VALF;
    anim.removedOnCompletion = NO;
    [scrollLabel.layer addAnimation:anim forKey:@"marquee"];
}

static void car_addDashedBorder(UIView *view, CGFloat cornerRadius) {
    static NSInteger kDashTag = 0x44415348;
    UIView *borderView = [view viewWithTag:kDashTag];
    if (!borderView) {
        borderView = [[UIView alloc] init];
        borderView.tag = kDashTag;
        borderView.userInteractionEnabled = NO;
        borderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:borderView];
    }
    borderView.frame = view.bounds;

    CAShapeLayer *dashLayer = nil;
    for (CALayer *sub in borderView.layer.sublayers) {
        if ([sub isKindOfClass:[CAShapeLayer class]]) { dashLayer = (CAShapeLayer *)sub; break; }
    }
    if (!dashLayer) {
        dashLayer = [CAShapeLayer layer];
        dashLayer.fillColor = nil;
        dashLayer.strokeColor = [UIColor colorWithWhite:0.78 alpha:1].CGColor;
        dashLayer.lineWidth = 1;
        dashLayer.lineDashPattern = @[@5, @3];
        [borderView.layer addSublayer:dashLayer];
    }
    dashLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderView.bounds cornerRadius:cornerRadius].CGPath;
    dashLayer.frame = borderView.bounds;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString * const kSectionIcons[] = {@"shield.slash.fill", @"eye.slash.fill", @"bolt.fill"};
    static const CGFloat kHeaderHeight = 38;
    static const CGFloat kIconSize = 16;
    static const CGFloat kGap = 6;

    CGFloat contentLeft = 20;

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, kHeaderHeight)];
    container.backgroundColor = [UIColor whiteColor];

    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(contentLeft, (kHeaderHeight - kIconSize) / 2, kIconSize, kIconSize)];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.tintColor = [UIColor colorWithWhite:0.4 alpha:1];
    if (@available(iOS 13.0, *)) {
        iconView.image = [UIImage systemImageNamed:kSectionIcons[section] withConfiguration:
            [UIImageSymbolConfiguration configurationWithPointSize:kIconSize weight:UIImageSymbolWeightMedium]];
    }
    [container addSubview:iconView];

    CGFloat labelX = CGRectGetMaxX(iconView.frame) + kGap;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 0, tableView.bounds.size.width - labelX - 20, kHeaderHeight)];
    label.text = kSectionTitles[section];
    label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    label.textColor = [UIColor colorWithWhite:0.4 alpha:1];
    [container addSubview:label];
    return container;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rows = [tableView numberOfRowsInSection:indexPath.section];
    BOOL isFirst = indexPath.row == 0;
    BOOL isLast = indexPath.row == rows - 1;

    if (!isFirst && !isLast) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *sectionBg = nil;
        for (UIView *sub in cell.superview.subviews) {
            if (sub != cell && !sub.hidden && CGRectIntersectsRect(sub.frame, cell.frame)
                && [NSStringFromClass([sub class]) containsString:@"Background"]) {
                sectionBg = sub;
                break;
            }
        }
        if (sectionBg) car_addDashedBorder(sectionBg, 10);
    });
}

- (void)switchChanged:(UISwitch *)sender {
    setSettingEnabled((CARSettingKey)sender.tag, sender.on);
}

@end

// ============================================================
// DynamicX 模板黑名单
// ============================================================

static BOOL isTemplateBlockedBySettings(NSString *name) {
    if (!name) return NO;
    if ([name containsString:@"new_user_award"] && isSettingEnabled(CARSettingNewUserZone)) return YES;
    if ([name containsString:@"banner_area"] && isSettingEnabled(CARSettingBanner)) return YES;
    if ([name containsString:@"guoguo_home_promotion"] && isSettingEnabled(CARSettingPromotion)) return YES;
    if (([name containsString:@"guoguo_guide_ads"] ||
         [name containsString:@"guoguo_feeds_adx"] ||
         [name containsString:@"guoguo_feeds_reward"]) && isSettingEnabled(CARSettingFeedsAd)) return YES;
    return NO;
}

// ============================================================
// 1. 开屏广告去除
// ============================================================

%hook CNSplashAdsSwitch

+ (BOOL)serviceOn {
    return isSettingEnabled(CARSettingSplashAd) ? NO : %orig;
}

+ (BOOL)isBlackListUser {
    return isSettingEnabled(CARSettingSplashAd) ? YES : %orig;
}

%end

%hook CNLaunchSplashManager

- (void)showAndDisappearAutomatically:(BOOL)arg1 completion:(id)completion {
    if (isSettingEnabled(CARSettingSplashAd)) {
        if (completion) ((void (^)(void))completion)();
        return;
    }
    %orig;
}

- (void)showAndDisappearAutomaticallyImp:(BOOL)arg1 {
    if (!isSettingEnabled(CARSettingSplashAd)) %orig;
}

- (void)showSplashWithConfigEntry:(id)entry {
    if (!isSettingEnabled(CARSettingSplashAd)) %orig;
}

- (void)showSplashPlaceholderView {
    if (!isSettingEnabled(CARSettingSplashAd)) %orig;
}

- (void)requestSplashAdsWithIsAppFirstLaunch:(BOOL)arg1 {
    if (!isSettingEnabled(CARSettingSplashAd)) %orig;
}

- (BOOL)isShowingSplash {
    return isSettingEnabled(CARSettingSplashAd) ? NO : %orig;
}

%end

%hook CNLaunchSplashViewController

- (void)viewDidLoad {
    %orig;
    if (isSettingEnabled(CARSettingSplashAd)) {
        [self.view removeFromSuperview];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)showSplash {
    if (!isSettingEnabled(CARSettingSplashAd)) %orig;
}

- (void)showWithCompletionBlock:(id)block {
    if (isSettingEnabled(CARSettingSplashAd)) {
        if (block) ((void (^)(void))block)();
        return;
    }
    %orig;
}

- (void)startExposureAndCountdown {
    if (!isSettingEnabled(CARSettingSplashAd)) %orig;
}

%end

%hook CNLaunchSplashInitialize

- (void)appDidFinishLaunchingWithConfiguration:(id)config {
    if (!isSettingEnabled(CARSettingSplashAd)) %orig;
}

%end

// ============================================================
// 2. DynamicX 模板级广告拦截
// ============================================================

%hook DXTemplateItem

- (BOOL)isAvailable {
    NSString *name = [(DXTemplateItem *)self name];
    if (isTemplateBlockedBySettings(name)) return NO;
    return %orig;
}

- (BOOL)isAvailableForDownload {
    NSString *name = [(DXTemplateItem *)self name];
    if (isTemplateBlockedBySettings(name)) return NO;
    return %orig;
}

%end

// ============================================================
// 3. 首页新用户专区去除 + 推荐区域高度修正
// ============================================================

static const char kCARHomeTableViewTag;

static BOOL car_viewContainsClass(UIView *view, NSString *className) {
    if ([NSStringFromClass([view class]) containsString:className]) return YES;
    for (UIView *sub in view.subviews) {
        if (car_viewContainsClass(sub, className)) return YES;
    }
    return NO;
}

static const CGFloat kCARAnchorHeadCut = 17;
static const CGFloat kCARAnchorListSelectTopGap = 28;
static const CGFloat kCARAnchorFloatSelectTopGap = 8;

static const char kCARIconRowIPKey;
static const char kCARAnchorRowIPKey;
static const char kCARPromoRowIPKey;

// 同步某类行的 indexPath 集合，返回集合是否发生变化
static BOOL car_syncRowSet(UITableView *tv, const void *key, NSIndexPath *ip, BOOL matches) {
    NSMutableSet<NSIndexPath *> *set = objc_getAssociatedObject(tv, key);
    if (!set) {
        set = [NSMutableSet set];
        objc_setAssociatedObject(tv, key, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    BOOL contains = [set containsObject:ip];
    if (matches == contains) return NO;
    if (matches) [set addObject:ip]; else [set removeObject:ip];
    return YES;
}

// 独立的 DynamicX 卡片行：cell 内容直接是 CNBDinamicXView，没有包裹列表背景视图
static BOOL car_isStandaloneDXCell(UITableViewCell *cell) {
    NSArray<UIView *> *subs = cell.contentView.subviews;
    return subs.count == 1 && [NSStringFromClass([subs.firstObject class]) containsString:@"CNBDinamicXView"];
}

static IMP car_originalHeightForRowIMP = NULL;
static BOOL car_heightSwizzled = NO;

static CGFloat car_swizzled_heightForRow(id self, SEL _cmd, UITableView *tv, NSIndexPath *ip) {
    CGFloat origHeight = ((CGFloat(*)(id, SEL, UITableView *, NSIndexPath *))car_originalHeightForRowIMP)(self, _cmd, tv, ip);

    if (!objc_getAssociatedObject(tv, &kCARHomeTableViewTag)) return origHeight;

    // 猜你喜欢：用高度启发式判断（高度超过屏幕 80% 的 cell 一定是推荐容器）
    if (isSettingEnabled(CARSettingRecommend) && origHeight > tv.frame.size.height * 0.8) return 0;

    if (isSettingEnabled(CARSettingPromotion)) {
        NSSet<NSIndexPath *> *promoIPs = objc_getAssociatedObject(tv, &kCARPromoRowIPKey);
        if ([promoIPs containsObject:ip]) return 0;
    }

    if (isSettingEnabled(CARSettingIconRow)) {
        NSSet<NSIndexPath *> *iconIPs = objc_getAssociatedObject(tv, &kCARIconRowIPKey);
        if ([iconIPs containsObject:ip]) return 0;

        NSSet<NSIndexPath *> *anchorIPs = objc_getAssociatedObject(tv, &kCARAnchorRowIPKey);
        if ([anchorIPs containsObject:ip] && origHeight > kCARAnchorHeadCut) return origHeight - kCARAnchorHeadCut;
    }

    return origHeight;
}

%hook CNBHomeViewController

- (void)changeNewUserAwardData:(id)data {
    if (!isSettingEnabled(CARSettingNewUserZone)) %orig;
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;

    UITableView *tv = nil;
    for (UIView *sub in self.view.subviews) {
        if ([sub isKindOfClass:[UITableView class]]) { tv = (UITableView *)sub; break; }
    }
    if (!tv) return;
    objc_setAssociatedObject(tv, &kCARHomeTableViewTag, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if (!car_heightSwizzled && tv.delegate) {
        Class delegateClass = [tv.delegate class];
        SEL sel = @selector(tableView:heightForRowAtIndexPath:);
        Method m = class_getInstanceMethod(delegateClass, sel);
        if (m) {
            car_originalHeightForRowIMP = method_getImplementation(m);
            method_setImplementation(m, (IMP)car_swizzled_heightForRow);
            car_heightSwizzled = YES;
            [tv reloadData];
        }
    }
}

%end

// ============================================================
// 4. DynamicX 广告事件处理器拦截
// ============================================================

%hook DXCNHomeNewUserEventHandler

- (void)handleEvent:(id)event args:(id)args context:(id)context {
    if (!isSettingEnabled(CARSettingNewUserZone)) %orig;
}

%end

%hook DXCNHomeBannerEventHandler

- (void)handleEvent:(id)event args:(id)args context:(id)context {
    if (!isSettingEnabled(CARSettingBanner)) %orig;
}

%end

%hook DXCNHomePromotionEventHandler

- (void)handleEvent:(id)event args:(id)args context:(id)context {
    if (!isSettingEnabled(CARSettingPromotion)) %orig;
}

%end

// ============================================================
// 5. PackageList DynamicX 模型广告拦截
// ============================================================

%hook CNGPackageListDinamicXModel

- (double)viewHeight {
    DXTemplateItem *dxItem = [(CNGPackageListDinamicXModel *)self dxItem];
    if (dxItem && isTemplateBlockedBySettings([dxItem name])) return 0;
    return %orig;
}

- (Class)viewClass {
    DXTemplateItem *dxItem = [(CNGPackageListDinamicXModel *)self dxItem];
    if (dxItem && isTemplateBlockedBySettings([dxItem name])) return nil;
    return %orig;
}

%end

%hook CNGPackageListDXModel

- (double)viewHeight {
    CNBDinamicXCardModel *card = [(CNGPackageListDXModel *)self cardModel];
    if (card) {
        DXTemplateItem *tmpl = [card origTemplate];
        if (!tmpl) tmpl = [card fetchedTemplateItem];
        if (tmpl && isTemplateBlockedBySettings([tmpl name])) return 0;
    }
    return %orig;
}

- (Class)viewClass {
    CNBDinamicXCardModel *card = [(CNGPackageListDXModel *)self cardModel];
    if (card) {
        DXTemplateItem *tmpl = [card origTemplate];
        if (!tmpl) tmpl = [card fetchedTemplateItem];
        if (tmpl && isTemplateBlockedBySettings([tmpl name])) return nil;
    }
    return %orig;
}

%end

// ============================================================
// 6. 首页「猜你喜欢」推荐广告去除
// ============================================================

%hook CNAdRecommendAdsViewController

- (void)viewDidLoad {
    %orig;
    if (isSettingEnabled(CARSettingRecommend)) {
        self.view.hidden = YES;
        self.view.frame = CGRectZero;
        self.view.clipsToBounds = YES;
        [self.view removeFromSuperview];
    }
}

- (void)loadData {
    if (!isSettingEnabled(CARSettingRecommend)) %orig;
}

- (void)loadTabData {
    if (!isSettingEnabled(CARSettingRecommend)) %orig;
}

%end

// ============================================================
// 6.1 物流详情页底部推荐去除（CNLogisticsRecommendView 所在的 CNMVVMCardView）
// ============================================================

%hook CNLDControllerLifeCycleHandler

- (id)addCustomViewModelsInEndByItem:(id)item frame:(CGRect)frame parentView:(id)parentView {
    if (isSettingEnabled(CARSettingLDRecommend)) return @[];
    return %orig;
}

%end

%hook CNNewLDTemplateContentView

- (void)updateData:(id)data {
    %orig;
    if (!isSettingEnabled(CARSettingLDRecommend) || ![self showMapView]) return;

    UIScrollView *scrollView = [self logisticsScrollView];
    if (!scrollView) return;

    CGFloat scrollViewHeight = scrollView.frame.size.height;
    CGFloat cardBottom = 0;
    Class cardClass = NSClassFromString(@"CNMVVMCardView");
    for (UIView *sub in scrollView.subviews) {
        if ([sub isKindOfClass:cardClass]) {
            cardBottom = CGRectGetMaxY(sub.frame);
            break;
        }
    }
    if (cardBottom <= 0) return;

    static const CGFloat kBottomPadding = 20;
    CGFloat offset = MAX(0, cardBottom + kBottomPadding - scrollViewHeight);
    [self setLogisticsScrollBestContentOffsetY:offset];

    if (![self hasChangedOffset]) {
        [scrollView setContentOffset:CGPointMake(0, offset)];
    }
}

%end

// ============================================================
// 6.2 物流详情页横幅广告拦截（CNLogisticsDetailNewBannerView）
// ============================================================

%hook CNLogisticsDetailBannerNewViewModel

- (Class)viewClass {
    return isSettingEnabled(CARSettingLDBanner) ? nil : %orig;
}

- (double)height {
    return isSettingEnabled(CARSettingLDBanner) ? 0 : %orig;
}

%end

%hook CNLogisticsDetailBrandAdViewModel

- (Class)viewClass {
    return isSettingEnabled(CARSettingLDBanner) ? nil : %orig;
}

- (double)height {
    return isSettingEnabled(CARSettingLDBanner) ? 0 : %orig;
}

%end

// 隐藏包裹分类标签头，筛选条上移并保留顶部间距
static void car_collapseAnchorHead(UIView *container, CGFloat selectTopGap) {
    UIView *head = nil, *select = nil;
    for (UIView *sub in container.subviews) {
        NSString *name = NSStringFromClass([sub class]);
        if ([name containsString:@"AnchorHeadView"]) head = sub;
        else if ([name containsString:@"AnchorSelectView"]) select = sub;
    }
    if (!head || !select) return;
    head.hidden = YES;
    CGRect frame = select.frame;
    frame.origin.y = head.frame.origin.y + selectTopGap;
    select.frame = frame;
}

%group CARAnchorViews

%hook CARMainCell
- (void)layoutSubviews {
    %orig;
    UITableViewCell *cell = (UITableViewCell *)self;
    UIView *superview = cell.superview;
    while (superview && ![superview isKindOfClass:[UITableView class]]) superview = superview.superview;
    UITableView *tv = (UITableView *)superview;
    if (!tv || !objc_getAssociatedObject(tv, &kCARHomeTableViewTag)) return;
    NSIndexPath *ip = [tv indexPathForCell:cell];
    if (!ip) return;

    BOOL isIcon = car_viewContainsClass(cell, @"CNBHomeIcon");
    BOOL isAnchor = !isIcon && car_viewContainsClass(cell, @"CNBPackageManagementListAnchorSectionView");
    BOOL isPromo = !isIcon && !isAnchor && car_isStandaloneDXCell(cell);

    BOOL changed = car_syncRowSet(tv, &kCARIconRowIPKey, ip, isIcon);
    changed |= car_syncRowSet(tv, &kCARAnchorRowIPKey, ip, isAnchor);
    changed |= car_syncRowSet(tv, &kCARPromoRowIPKey, ip, isPromo);
    if (changed) dispatch_async(dispatch_get_main_queue(), ^{ [tv reloadData]; });

    if ((isIcon && isSettingEnabled(CARSettingIconRow)) || (isPromo && isSettingEnabled(CARSettingPromotion))) {
        cell.clipsToBounds = YES;
    }
}
%end

%hook CARAnchorSectionView
- (void)layoutSubviews {
    %orig;
    if (isSettingEnabled(CARSettingIconRow)) car_collapseAnchorHead((UIView *)self, kCARAnchorListSelectTopGap);
}
%end

%hook CARAnchorFloatView
- (void)layoutSubviews {
    %orig;
    if (isSettingEnabled(CARSettingIconRow)) car_collapseAnchorHead((UIView *)self, kCARAnchorFloatSelectTopGap);
}
%end

%end

// 底栏：按文字隐藏指定项，剩余项在同一父视图内等分
static void car_collectTabItems(UIView *view, NSMutableArray<UIView *> *items) {
    NSString *name = NSStringFromClass([view class]);
    if ([name containsString:@"CNBTabBarGroup"] && [name hasSuffix:@"ItemView"]) {
        [items addObject:view];
        return;
    }
    for (UIView *sub in view.subviews) car_collectTabItems(sub, items);
}

static void car_collectTexts(UIView *view, NSMutableString *texts) {
    NSString *text = car_viewText(view);
    if (text.length) [texts appendString:text];
    for (UIView *sub in view.subviews) car_collectTexts(sub, texts);
}

static BOOL car_tabItemShouldHide(UIView *item) {
    NSMutableString *texts = [NSMutableString string];
    car_collectTexts(item, texts);
    return ([texts containsString:@"物换物"] && isSettingEnabled(CARSettingHideExchange)) ||
           ([texts containsString:@"发现"] && isSettingEnabled(CARSettingHideDiscover)) ||
           ([texts containsString:@"消息"] && isSettingEnabled(CARSettingHideMessage)) ||
           ([texts containsString:@"寄件券"] && isSettingEnabled(CARSettingHideCoupon));
}

static void car_applyTabItemVisibility(UIView *group) {
    NSMutableArray<UIView *> *items = [NSMutableArray array];
    car_collectTabItems(group, items);
    if (items.count < 2) return;

    NSMutableArray<UIView *> *visibleItems = [NSMutableArray array];
    for (UIView *item in items) {
        BOOL hide = car_tabItemShouldHide(item);
        item.hidden = hide;
        if (!hide) [visibleItems addObject:item];
    }
    if (visibleItems.count == items.count || visibleItems.count == 0) return;

    UIView *parent = items.firstObject.superview;
    if ([parent isKindOfClass:[UIStackView class]]) return;

    [visibleItems sortUsingComparator:^NSComparisonResult(UIView *a, UIView *b) {
        return a.frame.origin.x < b.frame.origin.x ? NSOrderedAscending : NSOrderedDescending;
    }];
    CGFloat itemWidth = parent.bounds.size.width / visibleItems.count;
    [visibleItems enumerateObjectsUsingBlock:^(UIView *item, NSUInteger index, BOOL *stop) {
        item.frame = CGRectMake(index * itemWidth, item.frame.origin.y, itemWidth, item.frame.size.height);
    }];
}

%group CARTabBarViews

%hook CARTabGroupView
- (void)layoutSubviews {
    %orig;
    car_applyTabItemVisibility((UIView *)self);
}
%end

%end

%hook UIButton
- (void)layoutSubviews {
    %orig;
    if (!self.hidden && [self.titleLabel.text isEqualToString:@"物换物"] && isSettingEnabled(CARSettingHideExchange)) {
        self.hidden = YES;
    }
}
%end

// 「我的」页是 H5：由「热门活动」文字节点向上取到不包含「我的订单」的最大祖先（即该卡片）并隐藏；
// 底部「每日首次添加包裹有奖」是卡片列表中的横向 adm-swiper 轮播（内容为图片，无文字），按同级节点一并隐藏
static NSString * const kCARMineActivityScript =
    @"(function(){"
    @"if(window.__carMineActivity)return;window.__carMineActivity=true;"
    @"var timer=null;"
    @"function hide(el){el.style.setProperty('display','none','important');}"
    @"function hideCard(){"
    @"var body=document.body;if(!body)return;"
    @"var walker=document.createTreeWalker(body,NodeFilter.SHOW_TEXT,null);"
    @"var node;"
    @"while((node=walker.nextNode())){"
    @"if(node.nodeValue.trim()!=='热门活动')continue;"
    @"var card=node.parentElement;"
    @"while(card.parentElement&&card.parentElement!==body&&card.parentElement.textContent.indexOf('我的订单')<0)card=card.parentElement;"
    @"var list=card.parentElement;"
    @"if(!list||list.textContent.indexOf('我的订单')<0)continue;"
    @"hide(card);"
    @"Array.prototype.forEach.call(list.children,function(child){if(child.classList.contains('adm-swiper-horizontal'))hide(child);});"
    @"}}"
    @"new MutationObserver(function(){clearTimeout(timer);timer=setTimeout(hideCard,100);})"
    @".observe(document.documentElement,{childList:true,subtree:true});"
    @"hideCard();"
    @"})();";

%hook WKWebView
- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    if (isSettingEnabled(CARSettingMineActivity)) {
        WKUserScript *script = [[WKUserScript alloc] initWithSource:kCARMineActivityScript
                                                      injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                   forMainFrameOnly:NO];
        [configuration.userContentController addUserScript:script];
    }
    return %orig;
}
%end

// 切换到消息页时自动触发「一键已读」：通过 DynamicX 事件分发链模拟点击
// DXRootView 通过 touchesBegan/touchesEnded 处理触摸，内部经过
// dx_getFlattendNode → hitTest:eventID: → widget.postEvent: 完成事件分发
static NSString * const kCARReadAllTitle = @"一键已读";
static const long long kDXTapEventID = 1848863463; // 0x6E33D367

static UIView *car_findVisibleViewWithText(UIView *view, NSString *text) {
    if (view.hidden || view.alpha < 0.01) return nil;
    if ([car_viewText(view) isEqualToString:text]) return view;
    for (UIView *sub in view.subviews) {
        UIView *found = car_findVisibleViewWithText(sub, text);
        if (found) return found;
    }
    return nil;
}

static BOOL car_dispatchDXTapOnLabel(UIView *label) {
    Class dxRootClass = NSClassFromString(@"DXRootView");
    if (!dxRootClass) return NO;

    UIView *dxRoot = label.superview;
    while (dxRoot && ![dxRoot isKindOfClass:dxRootClass]) dxRoot = dxRoot.superview;
    if (!dxRoot || !dxRoot.superview) return NO;

    SEL flatSel = NSSelectorFromString(@"dx_getFlattendNode");
    if (![dxRoot respondsToSelector:flatSel]) return NO;
    typedef id (*MsgSendId)(id, SEL);
    id flattenedNode = ((MsgSendId)objc_msgSend)(dxRoot, flatSel);
    if (!flattenedNode) return NO;

    CGPoint center = [label convertPoint:CGPointMake(CGRectGetMidX(label.bounds), CGRectGetMidY(label.bounds))
                                  toView:dxRoot.superview];

    SEL hitSel = NSSelectorFromString(@"hitTest:eventID:");
    if (![flattenedNode respondsToSelector:hitSel]) return NO;
    typedef id (*HitTestIMP)(id, SEL, CGPoint, long long);
    id widget = ((HitTestIMP)objc_msgSend)(flattenedNode, hitSel, center, kDXTapEventID);
    if (!widget) return NO;

    Class dxEventClass = NSClassFromString(@"DXEvent");
    SEL initSel = NSSelectorFromString(@"initWithEventId:");
    if (!dxEventClass || ![dxEventClass instancesRespondToSelector:initSel]) return NO;
    typedef id (*InitEventIMP)(id, SEL, long long);
    id event = ((InitEventIMP)objc_msgSend)([dxEventClass alloc], initSel, kDXTapEventID);

    typedef void (*MsgSendObj)(id, SEL, id);
    ((MsgSendObj)objc_msgSend)(event, NSSelectorFromString(@"setWidget:"), widget);
    ((MsgSendObj)objc_msgSend)(widget, NSSelectorFromString(@"postEvent:"), event);
    return YES;
}

static void car_autoReadAllMessages(UIWindow *window, NSInteger retries) {
    UIView *label = car_findVisibleViewWithText(window, kCARReadAllTitle);
    if (label && car_dispatchDXTapOnLabel(label)) return;

    if (retries <= 0) return;
    __weak UIWindow *weakWindow = window;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakWindow) car_autoReadAllMessages(weakWindow, retries - 1);
    });
}

%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    UIWindow *window = self.view.window;
    UIViewController *page = self.navigationController ?: self;
    if (!window || page.tabBarController.selectedViewController != page || !isSettingEnabled(CARSettingAutoReadMessage)) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        car_autoReadAllMessages(window, 3);
    });
}
%end

static Class car_swiftClass(NSArray<NSString *> *candidates) {
    for (NSString *name in candidates) {
        Class cls = NSClassFromString(name);
        if (cls) return cls;
    }
    return nil;
}

%ctor {
    %init;
    %init(CARTabBarViews,
          CARTabGroupView = car_swiftClass(@[@"CainiaoMainClient.CNBTabBarGroupView", @"Cainiao4iPhone.CNBTabBarGroupView", @"CNB4iPhone.CNBTabBarGroupView"]));
    %init(CARAnchorViews,
          CARMainCell = NSClassFromString(@"CNB4iPhone.CNBTableViewMainCell"),
          CARAnchorSectionView = NSClassFromString(@"Cainiao4iPhone.CNBPackageManagementListAnchorSectionView"),
          CARAnchorFloatView = NSClassFromString(@"Cainiao4iPhone.CNBPackageManagementListAnchorFloatView"));
}

// 持续修正首页 tableView contentSize
%hook UITableView

- (void)setContentSize:(CGSize)size {
    if (objc_getAssociatedObject(self, &kCARHomeTableViewTag)) {
        BOOL needsFix = isSettingEnabled(CARSettingRecommend) || isSettingEnabled(CARSettingIconRow);
        if (needsFix) {
            CGFloat maxY = 0;
            for (UITableViewCell *cell in self.visibleCells) {
                if (isSettingEnabled(CARSettingRecommend) && car_viewContainsClass(cell, @"CNRecommendCoordinator")) continue;
                if (isSettingEnabled(CARSettingIconRow) && car_viewContainsClass(cell, @"CNBHomeIcon")) continue;
                CGFloat bottom = CGRectGetMaxY(cell.frame);
                if (bottom > maxY) maxY = bottom;
            }
            if (maxY > 0 && size.height > maxY + 50) {
                size.height = maxY;
            }
        }
    }
    %orig(size);
}

%end

// ============================================================
// 7. 广告数据请求拦截
// ============================================================

%hook CNAdPitQueryTask

- (id)startQuery {
    return isSettingEnabled(CARSettingAdRequest) ? nil : %orig;
}

- (void)startAsyncQueryWithCallback:(id)callback {
    if (!isSettingEnabled(CARSettingAdRequest)) %orig;
}

%end

// ============================================================
// 8. 设置入口：任意页面长按底栏「首页」直接弹出开关面板
// ============================================================

static const NSInteger kCARLongPressTag = 0x434152;

%hook UITabBarController

- (void)viewDidAppear:(BOOL)animated {
    %orig;

    UITabBar *tabBar = self.tabBar;
    if (!tabBar || [tabBar viewWithTag:kCARLongPressTag]) return;

    UIView *marker = [[UIView alloc] init];
    marker.tag = kCARLongPressTag;
    marker.hidden = YES;
    [tabBar addSubview:marker];

    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc]
        initWithTarget:self action:@selector(car_tabBarLongPress:)];
    lp.minimumPressDuration = 0.8;
    lp.delaysTouchesBegan = YES;
    [tabBar addGestureRecognizer:lp];
}

%new
- (void)car_tabBarLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;

    UITabBar *tabBar = self.tabBar;
    CGPoint point = [gesture locationInView:tabBar];
    NSArray *items = tabBar.items;
    if (!items.count) return;

    CGFloat itemWidth = tabBar.bounds.size.width / items.count;
    if (point.x > itemWidth) return;

    UIViewController *topVC = self.selectedViewController;
    if ([topVC isKindOfClass:[UINavigationController class]]) {
        topVC = [(UINavigationController *)topVC visibleViewController];
    }
    if (!topVC) return;

    CainiaoAdRemoverSettingsVC *settingsVC = [[CainiaoAdRemoverSettingsVC alloc]
        initWithStyle:UITableViewStyleInsetGrouped];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;

    settingsVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemClose
        target:settingsVC action:@selector(car_dismiss)];

    if (@available(iOS 15.0, *)) {
        UISheetPresentationController *sheet = nav.sheetPresentationController;
        sheet.detents = @[UISheetPresentationControllerDetent.largeDetent];
        sheet.prefersGrabberVisible = YES;
    }

    [topVC presentViewController:nav animated:YES completion:nil];
}

%end

@implementation CainiaoAdRemoverSettingsVC (Actions)

- (void)car_dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)car_openRepo {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://repo.om2.cc"]
                                       options:@{} completionHandler:nil];
}

@end
