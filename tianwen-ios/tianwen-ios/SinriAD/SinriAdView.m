//
//  SinriAdView.m
//  ChiGui
//
//  Created by 倪 李俊 on 14/12/8.
//  Copyright (c) 2014年 com.sinri. All rights reserved.
//
//  Updated 2015/02/28
//

#import "SinriAdView.h"

static const NSString * SinriAd_IN_SDK_AD_ID=@"SDK-Original";

@implementation SinriAdView
/**
 iAd
 -------
 iAd supports different banner sizes for portrait and landscape apps. The exact size of advertisements depends on the device the banner is being shown on. On an iPhone, a portrait advertisement is 320 x 50 points and 480 x 32 points for a landscape advertisement. On an iPad, a portrait advertisement is 768 x 66 points and 1024 x 66 points for a landscape advertisement. In the future, additional sizes may be exposed by iAd.
 
 AdMob
 -------
 If use Smart Banner,height of ad on iPhone 50 for portrait and 32 for landscape, on iPad 90.
 */
+(CGFloat)recommendedBannerHeight{
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
        if([[UIApplication sharedApplication]statusBarOrientation]==UIInterfaceOrientationPortrait ||
           [[UIApplication sharedApplication]statusBarOrientation]==UIInterfaceOrientationPortraitUpsideDown){
            return 50;
        }else{
            return 32;
        }
    }else{
        if([[UIApplication sharedApplication]statusBarOrientation]==UIInterfaceOrientationPortrait ||
           [[UIApplication sharedApplication]statusBarOrientation]==UIInterfaceOrientationPortraitUpsideDown){
            return 66;
        }else{
            return 66;
        }
    }
}

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        _sinriBannerAdId= [SinriAd_IN_SDK_AD_ID copy];
        _sinriBannerText=@"~SinriAd Service~";
        _sinriBannerBackgroundColor=[UIColor lightGrayColor];
        _sinriBannerForegroundColor=[UIColor blueColor];
        _sinriBannerTargetUrl=@"http://www.everstray.com/";
        
        //[self performSelector:@selector(buildBanner) withObject:nil afterDelay:0.1];
        [self performSelector:@selector(buildGAD) withObject:nil afterDelay:0.1];
    }
    return self;
}

-(void)resetUI{
//    if(iadBanner){
//        [iadBanner setHidden:YES];
//        [iadBanner removeFromSuperview];
//        iadBanner=nil;
//    }
    if(gadBanner){
        [gadBanner setHidden:YES];
        [gadBanner removeFromSuperview];
        gadBanner = nil;
    }
    if(sinriBanner){
        [sinriBanner setHidden:YES];
        [sinriBanner removeFromSuperview];
        sinriBanner = nil;
    }
    if(_sinriBannerTimer){
        [_sinriBannerTimer invalidate];
        _sinriBannerTimer=nil;
    }
}
/*
-(void)buildIAD{
    iadBanner = [[ADBannerView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [iadBanner setDelegate:self];
    [self addSubview:iadBanner];
}
*/
-(void)buildGAD{
    [GADMobileAds configureWithApplicationID:_GAD_APP_ID];
    
    // 在屏幕顶部创建标准尺寸的视图。
    // 在GADAdSize.h中对可用的AdSize常量进行说明。
    gadBanner = [[GADBannerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    // 指定广告单元ID。
    gadBanner.adUnitID = _GAD_UNIT_ID;
    
    // 告知运行时文件，在将用户转至广告的展示位置之后恢复哪个UIViewController
    // 并将其添加至视图层级结构。
    gadBanner.rootViewController = _rootViewController;
    [self addSubview:gadBanner];
    
    [gadBanner setDelegate:self];
    
    // 启动一般性请求并在其中加载广告。
    [gadBanner loadRequest:[GADRequest request]];
}

-(void)buildBanner{
    sinriBanner=[UIButton buttonWithType:(UIButtonTypeRoundedRect)];
    [sinriBanner setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    [sinriBanner setTitle:_sinriBannerText forState:(UIControlStateNormal)];
    [sinriBanner setTitleColor:_sinriBannerForegroundColor forState:(UIControlStateNormal)];
    [sinriBanner setBackgroundColor:_sinriBannerBackgroundColor];
    
    [sinriBanner addTarget:self action:@selector(onSinriBanner:) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:sinriBanner];
    
    UILabel *adMask=[[UILabel alloc]initWithFrame:(CGRectMake(self.frame.size.width-50, 0, 50, 16))];
    [adMask setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.7]];
    [adMask setTextColor:[UIColor whiteColor]];
    [adMask setText:@"SinriAD"];
    [adMask setTextAlignment:(NSTextAlignmentCenter)];
    [adMask setFont:[UIFont systemFontOfSize:10]];
    [[adMask layer]setCornerRadius:5];
    [sinriBanner addSubview:adMask];
    
    [self performSelectorInBackground:@selector(loadSinriAd) withObject:nil];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark - load SinriAD

+(NSString *)URLQueryWithParams:(NSDictionary *)params
{
    NSMutableString *query = [NSMutableString string];
    NSArray *keys = params.allKeys;
    NSInteger count = keys.count;
    BOOL isNotFirst=NO;
    for (NSInteger i = 0; i < count; i++)
    {
        NSString *key = keys[i];
        id value = params[key];
        
        if([value isKindOfClass:[NSNull class]]){
            continue;
        }else{
            if (isNotFirst) {
                [query appendString:@"&"];
            }else{
                isNotFirst=YES;
            }
            
            [query appendFormat:@"%@=%@", key, [value isKindOfClass:[NSString class]] ? [SinriAdView URLEscape:(value)] : value];
        }
    }
    return query;
}

+(UIColor *)getColorFromHexString:(NSString*)colorString{
    /*
     colorString = [colorString stringByReplacingOccurrencesOfString:@"#" withString:@""];
     CGFloat r=1;
     CGFloat g=1;
     CGFloat b=1;
     CGFloat a=1;
     if(colorString.length>=6){
     r=[[NSString stringWithFormat: @"0x%@", [colorString substringWithRange:NSMakeRange(0,2)] ] integerValue]/255.0;
     g=[[NSString stringWithFormat: @"0x%@", [colorString substringWithRange:NSMakeRange(2,2)] ] integerValue]/255.0;
     b=[[NSString stringWithFormat: @"0x%@", [colorString substringWithRange:NSMakeRange(4,2)] ] integerValue]/255.0;
     if(colorString.length>=8){
     a=[[NSString stringWithFormat: @"0x%@", [colorString substringWithRange:NSMakeRange(6,2)] ] integerValue]/255.0;
     }
     
     }
     UIColor * color=[UIColor colorWithRed:r green:g blue:b alpha:a];
     _Log(@"%@ > %f %f %f %f = %@",colorString,r,g,b,a,color);
     return color;
     */
    return [UIColor colorWithHexString:colorString];
}

-(void)loadSinriAd{
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBundleIdentifier = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"];
    
    ASIdentifierManager *identifierManager = [ASIdentifierManager sharedManager];
    NSUUID *advertisingIdentifier = identifierManager.advertisingIdentifier;
    NSString *idfa = advertisingIdentifier.UUIDString;
    
    NSDictionary * request_parameters=@{
                                        @"dev_type":@"iOS",
                                        @"app_id":appBundleIdentifier?:@"unknown",
                                        @"app_ver":appVersionString?:@"unknown",
                                        @"client_id":idfa?:@"unknown",
                                        @"ad_size_type":@"banner"
                                        };
    
    NSMutableURLRequest * request=[[NSMutableURLRequest alloc]initWithURL:([NSURL URLWithString:@"https://sinri.cc/SinriAD/request"]) cachePolicy:(NSURLRequestReloadIgnoringCacheData) timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[SinriAdView URLQueryWithParams:request_parameters]dataUsingEncoding:NSUTF8StringEncoding]];
    
    /*
    NSHTTPURLResponse * response=nil;
    NSError * error=nil;
    NSData*data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(data){
        NSDictionary * dict=[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:&error];
        
        NSLog(@"Sinri Ad dict=%@",dict);
        
        if(dict){
            NSString * mediaType=dict[@"media_type"];
            NSString * url=dict[@"url"];
            if(mediaType && [mediaType isEqual:@"text"]){
                _sinriBannerAdId=dict[@"ad_id"]?:@"";
                
                NSDictionary * ui=dict[@"ui"];
                
                _sinriBannerText=ui[@"text"]?:@"";
                
                NSString * textColorHex=ui[@"text_color"]?:@"FFFFFF";
                NSString * backgroundColorHex=ui[@"background_color"]?:@"000000";
                _sinriBannerForegroundColor=[SinriAdView getColorFromHexString:textColorHex];
                _sinriBannerBackgroundColor=[SinriAdView getColorFromHexString:backgroundColorHex];
                
                _sinriBannerTargetUrl=url;
            }
            else{
                [self performSelectorOnMainThread:@selector(onSinriBannerDidFailWithError:) withObject:[[NSError alloc]initWithDomain:@"SinriAd" code:500 userInfo:@{@"reason":@"data error"}] waitUntilDone:NO];
                return;
            }
        }else{
            [self performSelectorOnMainThread:@selector(onSinriBannerDidFailWithError:) withObject:error waitUntilDone:NO];
            return;
        }
    }else{
        [self performSelectorOnMainThread:@selector(onSinriBannerDidFailWithError:) withObject:error waitUntilDone:NO];
        return;
    }
    
    //[self performSelectorOnMainThread:@selector(resetUI) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(refreshSinriBanner) withObject:nil waitUntilDone:YES];
    
    NSLog(@"SinriAD received");
    */
    ///new start
    
    [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary * dict=[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:&error];
            
            NSLog(@"Sinri Ad dict=%@",dict);
            
            if(dict){
                NSString * mediaType=dict[@"media_type"];
                NSString * url=dict[@"url"];
                if(mediaType && [mediaType isEqual:@"text"]){
                    _sinriBannerAdId=dict[@"ad_id"]?:@"";
                    
                    NSDictionary * ui=dict[@"ui"];
                    
                    _sinriBannerText=ui[@"text"]?:@"";
                    
                    NSString * textColorHex=ui[@"text_color"]?:@"FFFFFF";
                    NSString * backgroundColorHex=ui[@"background_color"]?:@"000000";
                    _sinriBannerForegroundColor=[SinriAdView getColorFromHexString:textColorHex];
                    _sinriBannerBackgroundColor=[SinriAdView getColorFromHexString:backgroundColorHex];
                    
                    _sinriBannerTargetUrl=url;
                }
                else{
                    [self performSelectorOnMainThread:@selector(onSinriBannerDidFailWithError:) withObject:[[NSError alloc]initWithDomain:@"SinriAd" code:500 userInfo:@{@"reason":@"data error"}] waitUntilDone:NO];
                    return;
                }
            }else{
                [self performSelectorOnMainThread:@selector(onSinriBannerDidFailWithError:) withObject:error waitUntilDone:NO];
                return;
            }
        }else{
            [self performSelectorOnMainThread:@selector(onSinriBannerDidFailWithError:) withObject:error waitUntilDone:NO];
            return;
        }
        
        //[self performSelectorOnMainThread:@selector(resetUI) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(refreshSinriBanner) withObject:nil waitUntilDone:YES];
        
        NSLog(@"SinriAD received");
    }];
    
    ///new over
    
    
    
}

-(void)refreshSinriBanner{
    [sinriBanner setTitle:_sinriBannerText forState:(UIControlStateNormal)];
    [sinriBanner setTitleColor:_sinriBannerForegroundColor forState:(UIControlStateNormal)];
    [sinriBanner setBackgroundColor:_sinriBannerBackgroundColor];
    
    if(_sinriBannerTimer){
        [_sinriBannerTimer invalidate];
        _sinriBannerTimer=nil;
    }
    _sinriBannerTimer=[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(onSinriBannerTimeUp:) userInfo:nil repeats:NO];
}

#pragma mark - target ad event

-(void)onSinriBanner:(id)sender{
    //report
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBundleIdentifier = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"];
    
    ASIdentifierManager *identifierManager = [ASIdentifierManager sharedManager];
    NSUUID *advertisingIdentifier = identifierManager.advertisingIdentifier;
    NSString *idfa = advertisingIdentifier.UUIDString;
    
    NSDictionary * request_parameters=@{
                                        @"dev_type":@"iOS",
                                        @"app_id":appBundleIdentifier?:@"unknown",
                                        @"app_ver":appVersionString?:@"unknown",
                                        @"client_id":idfa?:@"unknown",
                                        @"ad_size_type":@"banner",
                                        //TAP REPORT
                                        @"tap_report":@"YES",
                                        @"ad_id":_sinriBannerAdId?:@"",
                                        };
    
    NSMutableURLRequest * request=[[NSMutableURLRequest alloc]initWithURL:([NSURL URLWithString:@"https://sinri.cc/SinriAD/click"]) cachePolicy:(NSURLRequestReloadIgnoringCacheData) timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[SinriAdView URLQueryWithParams:request_parameters]dataUsingEncoding:NSUTF8StringEncoding]];
    
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:([NSOperationQueue mainQueue])
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        //        Log(@"= = AD TAP REPORT = =\nresponse: %@\ndata: %@\nerror: %@",response,[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding],connectionError);
//    }];
    
    [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]]dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"SinriAD Request Done");
    }];
    //open
    //[[UIApplication sharedApplication]openURL:[NSURL URLWithString:_sinriBannerTargetUrl]];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:_sinriBannerTargetUrl] options:@{} completionHandler:^(BOOL success) {
        NSLog(@"Clicked SinriAD");
    }];
}

-(void)onSinriBannerTimeUp:(NSTimer*)timer{
    [_sinriBannerTimer invalidate];
    _sinriBannerTimer = nil;
    
    [self resetUI];
    //[self buildIAD];
    [self buildGAD];
    NSLog(@"SinriAD time up");
}

-(void)onSinriBannerDidFailWithError:(NSError*)error{
    [self resetUI];
    //[self buildIAD];
    [self buildGAD];
    NSLog(@"SinriAD receive ad failed");
}
/*
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    [self resetUI];
    if(_useAdMob){
        [self buildGAD];
    }else{
        [self buildBanner];
    }
    NSLog(@"iOS receive iad failed");
}
*/
- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{
    [self resetUI];
    [self buildBanner];
    NSLog(@"iOS receive admob failed");
}

//

//
+(NSString *)URLEscape:(NSString *)string
{
    //    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
    //                                                                                 (CFStringRef)string,
    //                                                                                 NULL,
    //                                                                                 CFSTR("!*'();:@&=+$,/?%#[]"),
    //                                                                                 kCFStringEncodingUTF8);
    return [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

//
+(NSString *)URLUnEscape:(NSString *)string
{
    //    return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)string,CFSTR(""),kCFStringEncodingUTF8);
    return [string stringByRemovingPercentEncoding];
}

@end

@implementation UIColor (SinriAdViewHexColor)

+ (UIColor *) colorWithHexString: (NSString *) hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    colorString = [[colorString stringByReplacingOccurrencesOfString: @"0X" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            //[NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            NSLog(@"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString);
            
            alpha = 1;
            red   = (arc4random() % 256) / 255.0;
            green = (arc4random() % 256) / 255.0;
            blue  = (arc4random() % 256) / 255.0;
            
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

@end
