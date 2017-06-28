//
//  TianwenSettings.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/26.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "TianwenSettings.h"

@implementation TianwenSettings

+(void)setWarningDisplayStyle:(NSString*)style{
    [[NSUserDefaults standardUserDefaults]setObject:style forKey:@"DynamicTianwenWarningViewStyle"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
+(NSString*)warningDisplayStyle{
    NSString * style=[[NSUserDefaults standardUserDefaults]stringForKey:@"DynamicTianwenWarningViewStyle"];
    if(!style){
        style=@"WarningDisplayStyleList";
        [TianwenSettings setWarningDisplayStyle:style];
    }
    return style;
}
+(NSDictionary*)warningDisplayStylePossibilites{
    return @{
             @"WarningDisplayStyleList":@"List",
             @"WarningDisplayStyleTree":@"Tree",
             };
}


@end
