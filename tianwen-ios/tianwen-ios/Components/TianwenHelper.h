//
//  TianwenHelper.h
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/23.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TianwenHelper : NSObject

+(NSDate*)dateFromISO8601String:(NSString*)dateWithTZ;
+(NSString*)localizedDateStringFromISO8601String:(NSString*)dateWithTZ;

+(NSString*)stringOfDate:(NSDate*)date inFormat:(NSString*)format;
+(NSDate*)dateOfString:(NSString*)string inFormat:(NSString*)format;

+(NSString*)stringOfDateForMySQL:(NSDate*)date;
+(NSDate*)dateOfStringForMySQL:(NSString*)string;

@end
