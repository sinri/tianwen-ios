//
//  TianwenSettings.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/26.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TianwenSettings : NSObject

+(void)setWarningDisplayStyle:(NSString*)style;
+(NSString*)warningDisplayStyle;
+(NSDictionary*)warningDisplayStylePossibilites;

@end
