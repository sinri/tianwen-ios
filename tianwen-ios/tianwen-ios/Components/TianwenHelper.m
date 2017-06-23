//
//  TianwenHelper.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/23.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "TianwenHelper.h"

@implementation TianwenHelper

+(NSDate*)dateFromISO8601String:(NSString*)dateWithTZ{
    return [[[NSISO8601DateFormatter alloc]init] dateFromString:dateWithTZ];
}
+(NSString *)localizedDateStringFromISO8601String:(NSString *)dateWithTZ{
    NSDate*date=[TianwenHelper dateFromISO8601String:dateWithTZ];
    if(!date){
        NSLog(@"localizedDateStringFromISO8601String Error for [%@]",dateWithTZ);
        //return [NSString stringWithFormat:@"!%@",dateWithTZ];
        return dateWithTZ;
    }else{
        NSLog(@"localizedDateStringFromISO8601String OK for [%@]",dateWithTZ);
    }
    return [TianwenHelper stringOfDateForMySQL:date];
}

/**
 format: @"yyyy'-'MM'-'dd HH':'mm':'ss";
 **/
+(NSString*)stringOfDate:(NSDate*)date inFormat:(NSString*)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    return [dateFormatter stringFromDate:date];
}

+(NSDate*)dateOfString:(NSString*)string inFormat:(NSString*)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    return [dateFormatter dateFromString:string];
}

+(NSString*)stringOfDateForMySQL:(NSDate*)date{
    return [TianwenHelper stringOfDate:date inFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss"];
}

+(NSDate*)dateOfStringForMySQL:(NSString*)string{
    return [TianwenHelper dateOfString:string inFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss"];
}

@end
