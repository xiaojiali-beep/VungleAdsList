//
//  VungleManager.h
//  test
//
//  Created by jiali xiao on 2022/5/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VungleAdsType) {
    VUNGLE_INTERSTITIAL_ADS = 0,
    VUNGLE_REWARDED_ADS,
    VUNGLE_BANNER_ADS,
    VUNGLE_MREC_ADS,
};

typedef void (^VMCompletionHandler)(bool status);

@interface VungleManager : NSObject
@property(nonatomic, assign, readwrite) BOOL isInitialized;
@property(nonatomic, assign, readwrite) BOOL isLoaded;
@property(nonatomic, assign, readwrite) BOOL isPlayed;

+ (instancetype)instanceShared;
//start to initialize vungle SDK.
- (void)startVungleWithCompletionHandler:(VMCompletionHandler)handler;
//start to load ads and play ads.
- (void)startLoadAds:(VungleAdsType)type forViewC:(UIViewController*)viewC orView:(UIView*)view;
//stop play ads.
- (void)finishDisplayingAd;       
@end
