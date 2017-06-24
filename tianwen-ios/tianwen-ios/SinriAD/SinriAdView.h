//
//  SinriAdView.h
//  Goodle AdMob SDK For iOS 7.0.0 Required
//
//  Created by 倪 李俊 on 14/12/8.
//  Copyright (c) 2014年 com.sinri. All rights reserved.
//
//  Updated 2015/02/28
//


@import GoogleMobileAds;
@import AdSupport;

#import <UIKit/UIKit.h>

//#import <iAd/iAd.h>

@interface SinriAdView : UIView
<
//ADBannerViewDelegate,
GADBannerViewDelegate
>
{
    //ADBannerView * iadBanner;
    GADBannerView * gadBanner;
    UIButton * sinriBanner;
}
+(CGFloat)recommendedBannerHeight;

@property BOOL useAdMob;
@property NSString * GAD_APP_ID;
@property NSString * GAD_UNIT_ID;
@property UIViewController * rootViewController;

@property NSString * sinriBannerAdId;
@property NSString * sinriBannerText;
@property UIColor * sinriBannerBackgroundColor;
@property UIColor * sinriBannerForegroundColor;
@property NSString * sinriBannerTargetUrl;

@property NSDictionary * sinriBannerInfoDict;
@property NSTimer * sinriBannerTimer;

@end

@interface UIColor (SinriAdViewHexColor)

+ (UIColor *) colorWithHexString: (NSString *) hexString;
+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length;

@end
