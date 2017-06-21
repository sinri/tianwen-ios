//
//  TianwenAPI.m
//  tianwen-ios
//
//  Created by 倪 李俊 on 2017/6/19.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "TianwenAPI.h"
#import "APIClient.h"

@implementation TianwenAPI

+(NSDictionary*)CloudAssetsDoctor:(NSString*)plan forAccount:(AliyunAccountModel*)account{
    NSDictionary*requestParams=@{@"region_list":[account regions]};
    NSDictionary*responseDict=[APIClient callTianwenApi:[NSString stringWithFormat:@"CloudAssetsDoctor/%@",plan] withPostData:requestParams forAccount:account];
    //NSLog(@"CloudAssetsDoctor with %@ response for %@: %@",plan,[account username],responseDict);
    if(!responseDict){
        return nil;
    }
    return responseDict;
}

@end
