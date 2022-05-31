//
//  VungleManager.m
//  test
//
//  Created by jiali xiao on 2022/5/30.
//

#import <Foundation/Foundation.h>
#import "VungleManager.h"
#import <VungleSDK/VungleSDK.h>

static NSString *const kVungleTestAppID = @"6293520cecb7371511c45a37";
static NSString *const kVungleInterstitialPlacementID = @"DEFAULT-1592267";
static NSString *const kVungleRewardedPlacementID = @"REWARD-0272289";
static NSString *const kVungleBannerPlacementID = @"BANNER-9484057";
static NSString *const kVungleMRECPlacementID = @"MREC-5826192";


@interface VungleManager ()<VungleSDKDelegate>

@property(nonatomic, assign) VungleAdsType AdsType;
@property(nonatomic, weak) UIViewController *viewC;
@property(nonatomic, weak) UIView *view;
@property(nonatomic, strong) NSString* placementID;
@property(nonatomic, copy)VMCompletionHandler completeHandler;
- (void)loadVungleAds;
- (void)playVungleAds;

@end

@implementation VungleManager

+ (instancetype)instanceShared {
    static VungleManager *manager = nil;
    static dispatch_once_t onceTaken = 0;
    
    dispatch_once(&onceTaken, ^{
        manager = [[VungleManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.isLoaded = NO;
        self.isPlayed = NO;
        self.isInitialized = NO;
    }
    
    return self;
}

- (void)loadVungleAds{
    NSError *error = nil;
    
    switch(self.AdsType){
        case VUNGLE_INTERSTITIAL_ADS:
        case VUNGLE_REWARDED_ADS:
        case VUNGLE_MREC_ADS:
        {
            if ([[VungleSDK sharedSDK] loadPlacementWithID:self.placementID error:&error]) {
                NSLog(@" placement loaded successfully");

            } else {
                if (error) {
                    NSLog(@"Unable to load placement with reference ID :%@, Error %@", kVungleInterstitialPlacementID, error);
                }
            }
            break;
        }
        case VUNGLE_BANNER_ADS:{
            if ([[VungleSDK sharedSDK] loadPlacementWithID:kVungleBannerPlacementID withSize:VungleAdSizeBannerShort error:&error]){
                NSLog(@"Banner placement loaded successfully");

            } else {
                if (error) {
                    NSLog(@"Unable to load placement with reference ID :%@, Error %@", kVungleBannerPlacementID, error);
                }
            }
            break;
       }
    }
}

- (void)startVungleWithCompletionHandler:(VMCompletionHandler)handler{
    //Accept GDPR status.
    [[VungleSDK sharedSDK] updateConsentStatus:VungleConsentDenied consentMessageVersion:@"Accepted"];
    
    // deny CCPA.
    [[VungleSDK sharedSDK] updateCCPAStatus:VungleCCPADenied];
 
    [[VungleSDK sharedSDK] setDelegate:self];
    [[VungleSDK sharedSDK] setLoggingEnabled:YES];
    
    self.completeHandler = handler;
    
    NSError *error = nil;
    if(![[VungleSDK sharedSDK] startWithAppId:kVungleTestAppID options:nil error:&error]) {
        NSLog(@"Error while starting VungleSDK %@",[error localizedDescription]);

        return;
    }
}

- (void)startLoadAds:(VungleAdsType)type forViewC:(UIViewController*)_viewC orView:(UIView*)_view{
    self.AdsType = type;
    self.viewC = _viewC;
    self.view = _view;
    self.isLoaded = NO;
    self.isPlayed = NO;
    
    switch(self.AdsType){
        case VUNGLE_INTERSTITIAL_ADS:
        {
            self.placementID = kVungleInterstitialPlacementID;
            break;
        }
        case VUNGLE_REWARDED_ADS:
        {
            self.placementID = kVungleRewardedPlacementID;
            break;
        }
        case VUNGLE_BANNER_ADS:
        {
            self.placementID = kVungleBannerPlacementID;
            break;
        }
        case VUNGLE_MREC_ADS:
        {
            self.placementID = kVungleMRECPlacementID;
            break;
        }
    }
    
    dispatch_queue_t queue=dispatch_get_main_queue();
    dispatch_async(queue, ^{
        self.isLoaded = YES;
        self.isPlayed = NO;
        [self loadVungleAds];
    });
}

- (void)finishDisplayingAd{
    if(self.isPlayed){
        if([[VungleSDK sharedSDK] isAdCachedForPlacementID:self.placementID]){
            NSLog(@"%@ is loaded!", self.placementID);
            dispatch_queue_t queue=dispatch_get_main_queue();
            dispatch_async(queue, ^{
                [[VungleSDK sharedSDK] finishDisplayingAd:self.placementID];
            });
        }
    }
}

- (void)playVungleAds{
    if(!self.isPlayed)
        self.isPlayed = YES;
    else
        return;
 
    NSDictionary *options = @{VunglePlayAdOptionKeyOrientations: @(UIInterfaceOrientationMaskPortrait),
                              VunglePlayAdOptionKeyUser: @"Xiao Jiali",
                              VunglePlayAdOptionKeyIncentivizedAlertBodyText : @"Thanks for watching the video",
                              VunglePlayAdOptionKeyIncentivizedAlertCloseButtonText : @"Close",
                              VunglePlayAdOptionKeyIncentivizedAlertContinueButtonText : @"Keep Watching",
                              VunglePlayAdOptionKeyIncentivizedAlertTitleText : @"Careful!"};
    
    NSError *error;
    
    switch(self.AdsType){
        case VUNGLE_INTERSTITIAL_ADS:
        {
            [[VungleSDK sharedSDK] playAd:self.viewC options:nil placementID:kVungleInterstitialPlacementID error:&error];
            if (error) {
                NSLog(@"Error encountered playing ad: %@", error);
            }
            break;
        }
        case VUNGLE_REWARDED_ADS:
        {
            [[VungleSDK sharedSDK] playAd:self.viewC options:options placementID:kVungleRewardedPlacementID error:&error];
            if (error) {
                NSLog(@"Error encountered playing ad: %@", error);
            }
            break;
        }
        case VUNGLE_BANNER_ADS:
        {
            [[VungleSDK sharedSDK] addAdViewToView:self.view withOptions:nil placementID:kVungleBannerPlacementID error:&error];
            if (error) {
                NSLog(@"Error encountered playing ad: %@", error);
            break;
        }
        case VUNGLE_MREC_ADS:
        {
            [[VungleSDK sharedSDK] addAdViewToView:self.view withOptions:nil placementID:kVungleMRECPlacementID error:&error];
            if (error) {
                NSLog(@"Error encountered trying to load ad %@",error);
            }
        }
    }
}
}

// 实现的回调
- (void)vungleSDKDidInitialize{
// 初始化成功
    self.isInitialized = YES;
    if(self.completeHandler)
        self.completeHandler(YES);
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error{
// 初始化失败
    if(self.completeHandler)
        self.completeHandler(NO);
}


- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(nullable NSString *)_placementID error:(nullable NSError *)error{
// 缓存广告成功或失败
    if(self.placementID.length>0 && [self.placementID isEqualToString:_placementID]) {
        if([[VungleSDK sharedSDK] isAdCachedForPlacementID:self.placementID]){
        NSLog(@"%@ is loaded!", self.placementID);
        dispatch_queue_t queue=dispatch_get_main_queue();
        dispatch_async(queue, ^{
            [self playVungleAds];
        });
        }
    }

}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID{
// 广告即将开始播放
}

- (void)vungleDidShowAdForPlacementID:(nullable NSString *)placementID{
    // 广告开始播放
}

- (void)vungleTrackClickForPlacementID:(nullable NSString *)placementID{
    // 广告被点击
}

- (void)vungleWillLeaveApplicationForPlacementID:(nullable NSString *)placementID{
    // 离开应用，例如用户点击广告，跳转商店
}

- (void)vungleRewardUserForPlacementID:(nullable NSString *)placementID{
    // 使用与奖励广告位，当用户观看80%以上时触发
}

- (void)vungleWillCloseAdForPlacementID:(nonnull NSString *)placementID{
    // 用户点击关闭按钮，即将关闭广告
}

- (void)vungleDidCloseAdForPlacementID:(nonnull NSString *)placementID{
    // 用户点击关闭按钮，关闭广告
}

- (void)vungleAdViewedForPlacement:(NSString *)placementID{
    // 用户观看了一帧广告
}



@end

