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

+(NSDictionary *)ProductList:(NSString *)type forAccount:(AliyunAccountModel *)account{
    NSDictionary*requestParams=@{@"region_list":[account regions]};
    NSDictionary*responseDict=[APIClient callTianwenApi:[NSString stringWithFormat:@"ProductList/%@",type] withPostData:requestParams forAccount:account];
    if(!responseDict){
        return nil;
    }
    return responseDict;
}

+(NSDictionary*)Product:(NSString*)type instance:(NSString*)instance_id inRegion:(NSString*)region_id forAccount:(AliyunAccountModel*)account{
    NSDictionary*requestParams=@{
                                 @"region_id":region_id,
                                 @"instance_id":instance_id
                                 };
    NSDictionary*responseDict=[APIClient callTianwenApi:[NSString stringWithFormat:@"Product/%@",type] withPostData:requestParams forAccount:account];
    if(!responseDict){
        return nil;
    }
    return responseDict;
}

@end
