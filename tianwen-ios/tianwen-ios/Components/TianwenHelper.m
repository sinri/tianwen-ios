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


+(NSString*)hiddenForScreenshot:(NSString*)string{
    if(/* DISABLES CODE */ (NO)){
        NSLog(@"FOR_SCREENSHOT: %@",string);
        NSString *head=(string && [string length]>2)?[string substringToIndex:2]:@"";
        return [head stringByAppendingString:@"***(Hidden For Screenshot)"];
    }
    return string;
}

+(UIColor*)colorForProgressRate:(CGFloat)progress{
    CGFloat r=0;
    CGFloat g=0;
    CGFloat b=0;
    if(progress<=0.40){
        r=progress/0.40;
        g=0.8;
        b=0.2;
    }
    else if(progress>0.40 && progress<0.80){
        r=1;
        g=0.8-(progress-0.4)/0.4*0.5;
        b=0.2-(progress-0.4)/0.4*0.2;
    }
    else {
        r=1;
        g=0.3-(progress-0.8)/0.2*0.3;
        b=0;
    }
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

@end
